/// Port for foreground local notification rendering.
abstract interface class PushLocalNotificationsGateway {
  /// Initializes local notifications and tap callbacks.
  Future<void> initialize({
    required void Function(Map<String, String> data) onNotificationTap,
  });

  /// Shows one foreground local notification.
  Future<void> showForegroundNotification({
    required String notificationId,
    required String? title,
    required String body,
    required Map<String, String> data,
    required String? imageUrl,
  });
}
