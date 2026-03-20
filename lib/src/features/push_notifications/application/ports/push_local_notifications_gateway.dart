/// Localized notification-channel copy used on Android.
final class PushNotificationChannelLocalization {
  /// Creates one localized channel-copy payload.
  const PushNotificationChannelLocalization({
    required this.name,
    required this.description,
  });

  /// Channel display name.
  final String name;

  /// Channel description shown in Android system settings.
  final String description;
}

/// Port for foreground local notification rendering.
abstract interface class PushLocalNotificationsGateway {
  /// Updates localized channel copy used for Android notifications.
  void configureChannelLocalization({
    required PushNotificationChannelLocalization channelLocalization,
  });

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
