import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notifications_page_dto.dart';
import 'package:memuno_app/src/features/notifications/data/mappers/notification_mapper.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Repository implementation for notification feature operations.
final class NotificationsRepositoryImpl implements NotificationsRepository {
  /// Creates the repository.
  const NotificationsRepositoryImpl({
    required NotificationsDatasource notificationsDatasource,
    required NotificationMapper notificationMapper,
    required FailureMapper failureMapper,
  }) : _notificationsDatasource = notificationsDatasource,
       _notificationMapper = notificationMapper,
       _failureMapper = failureMapper;

  final NotificationsDatasource _notificationsDatasource;
  final NotificationMapper _notificationMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads one paginated notifications page and maps to domain entities.
  Future<PaginatedPage<NotificationEntity, NotificationCursorEntity>>
  listNotifications({
    String? search,
    required int limit,
    NotificationCursorEntity? cursor,
  }) async {
    try {
      final NotificationsPageDto dto = await _notificationsDatasource
          .listNotifications(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return PaginatedPage<NotificationEntity, NotificationCursorEntity>(
        items: dto.items
            .map(_notificationMapper.toDomain)
            .toList(growable: false),
        nextCursor: _cursorFrom(dto),
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Marks one notification as read.
  Future<void> markNotificationRead({required String notificationId}) async {
    try {
      await _notificationsDatasource.markNotificationRead(
        notificationId: notificationId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Marks all unread notifications as read and returns affected row count.
  Future<int> markAllNotificationsRead() async {
    try {
      return _notificationsDatasource.markAllNotificationsRead();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  NotificationCursorEntity? _cursorFrom(NotificationsPageDto dto) {
    final DateTime? createdAt = dto.nextCursorCreatedAt;
    final String? id = dto.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return NotificationCursorEntity(createdAt: createdAt, id: id);
  }
}
