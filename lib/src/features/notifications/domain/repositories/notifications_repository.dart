import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_entity.dart';

/// Repository contract for notifications read/update operations.
abstract interface class NotificationsRepository {
  /// Loads one paginated notifications page.
  Future<NotificationListPageEntity> listNotifications({
    /// Optional search term applied to actor name/friendship code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    NotificationCursorEntity? cursor,
  });

  /// Marks one notification as read for the current user.
  Future<void> markNotificationRead({
    /// Notification id to mark as read.
    required String notificationId,
  });

  /// Marks all unread notifications as read and returns affected row count.
  Future<int> markAllNotificationsRead();

  /// Returns unread notifications count for the current user.
  Future<int> unreadNotificationsCount();
}
