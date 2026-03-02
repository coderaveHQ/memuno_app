import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Usecase for loading paginated notifications.
final class ListNotificationsUsecase {
  /// Creates the usecase.
  const ListNotificationsUsecase({required NotificationsRepository repository})
    : _repository = repository;

  final NotificationsRepository _repository;

  /// Executes a paginated notifications query.
  Future<PaginatedPage<NotificationEntity, NotificationCursorEntity>> call({
    /// Optional search term applied to actor name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    NotificationCursorEntity? cursor,
  }) {
    return _repository.listNotifications(
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
