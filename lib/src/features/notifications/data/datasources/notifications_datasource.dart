import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_dto.dart';

/// Low-level datasource for notification RPC calls.
abstract interface class NotificationsDatasource {
  /// Loads one page of notifications.
  Future<NotificationListPageDto> listNotifications({
    /// Optional search term applied server-side.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Marks one notification as read for the current user.
  Future<void> markNotificationRead({
    /// Notification id to mark as read.
    required String notificationId,
  });

  /// Marks all unread notifications as read and returns affected row count.
  Future<int> markAllNotificationsRead();
}
