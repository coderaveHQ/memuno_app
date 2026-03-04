import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/list_notifications_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/mark_all_notifications_read_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/mark_notification_read_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/list_notifications_usecase.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_list_provider.g.dart';

/// Async paginated controller for notifications list state.
@Riverpod(keepAlive: true)
class NotificationsList extends _$NotificationsList
    with
        AsyncPaginationMixin<
          NotificationListPageItemEntity,
          NotificationCursorEntity
        >,
        AsyncPaginationSearchMixin<
          NotificationListPageItemEntity,
          NotificationCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            NotificationListPageItemEntity,
            NotificationCursorEntity
          >
        > {
  Logger get _logger => ref.read(loggerProvider);

  @override
  /// Builds the initial notifications page.
  Future<
    PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
  >
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one notifications page from the list usecase.
  Future<
    PaginatedPage<NotificationListPageItemEntity, NotificationCursorEntity>
  >
  loadPage({required int limit, NotificationCursorEntity? cursor}) async {
    final ListNotificationsUsecase usecase = ref.watch(
      listNotificationsUsecaseProvider,
    );
    final NotificationListPageEntity page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );
    return PaginatedPage<
      NotificationListPageItemEntity,
      NotificationCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the notifications list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next notifications page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Marks one notification as read with optimistic rollback and silent failure.
  Future<void> markAsRead(NotificationListPageItemEntity notification) async {
    if (notification.notificationIsRead) {
      return;
    }

    final PaginatedListState<
      NotificationListPageItemEntity,
      NotificationCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String notificationId = notification.notificationId;
    final bool wasRead = notification.notificationIsRead;

    final int index = current.items.indexWhere(
      (NotificationListPageItemEntity item) =>
          item.notificationId == notificationId,
    );
    if (index < 0) {
      return;
    }

    try {
      await runOptimisticUpdate<void>(
        apply:
            (
              PaginatedListState<
                NotificationListPageItemEntity,
                NotificationCursorEntity
              >
              state,
            ) {
              return _setNotificationReadState(
                state,
                notificationId: notificationId,
                isRead: true,
              );
            },
        rollback:
            (
              PaginatedListState<
                NotificationListPageItemEntity,
                NotificationCursorEntity
              >
              state,
            ) {
              return _setNotificationReadState(
                state,
                notificationId: notificationId,
                isRead: wasRead,
              );
            },
        operation: () async {
          final MarkNotificationReadUsecase usecase = ref.read(
            markNotificationReadUsecaseProvider,
          );
          await usecase(notificationId: notificationId);
        },
      );
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to mark notification read (silent): $notificationId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Marks all unread notifications as read with optimistic rollback.
  Future<void> markAllAsRead() async {
    final PaginatedListState<
      NotificationListPageItemEntity,
      NotificationCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final List<String> unreadIds = current.items
        .where(
          (NotificationListPageItemEntity item) => !item.notificationIsRead,
        )
        .map((NotificationListPageItemEntity item) => item.notificationId)
        .toList(growable: false);

    if (unreadIds.isEmpty) {
      return;
    }

    try {
      await runOptimisticUpdate<int>(
        apply:
            (
              PaginatedListState<
                NotificationListPageItemEntity,
                NotificationCursorEntity
              >
              state,
            ) {
              return _setManyNotificationsReadState(
                state,
                notificationIds: unreadIds,
                isRead: true,
              );
            },
        rollback:
            (
              PaginatedListState<
                NotificationListPageItemEntity,
                NotificationCursorEntity
              >
              state,
            ) {
              return _setManyNotificationsReadState(
                state,
                notificationIds: unreadIds,
                isRead: false,
              );
            },
        operation: () {
          final MarkAllNotificationsReadUsecase usecase = ref.read(
            markAllNotificationsReadUsecaseProvider,
          );
          return usecase();
        },
      );
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to mark all notifications read (silent).',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
  _setNotificationReadState(
    PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
    state, {
    required String notificationId,
    required bool isRead,
  }) {
    final List<NotificationListPageItemEntity> nextItems = state.items
        .map((NotificationListPageItemEntity item) {
          if (item.notificationId != notificationId) {
            return item;
          }

          return isRead ? item.markRead() : item.markUnread();
        })
        .toList(growable: false);

    return state.copyWith(
      items: List<NotificationListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
  _setManyNotificationsReadState(
    PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
    state, {
    required List<String> notificationIds,
    required bool isRead,
  }) {
    final Set<String> ids = notificationIds.toSet();

    final List<NotificationListPageItemEntity> nextItems = state.items
        .map((NotificationListPageItemEntity item) {
          if (!ids.contains(item.notificationId)) {
            return item;
          }

          return isRead ? item.markRead() : item.markUnread();
        })
        .toList(growable: false);

    return state.copyWith(
      items: List<NotificationListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  NotificationCursorEntity? _cursorFromPage(NotificationListPageEntity page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return NotificationCursorEntity(createdAt: createdAt, id: id);
  }
}
