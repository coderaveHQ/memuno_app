import 'package:memuno_app/src/features/push_notifications/application/entities/push_incoming_message.dart';

/// Port for push-messaging SDK interactions.
abstract interface class PushMessagingGateway {
  /// Stream of refreshed device tokens.
  Stream<String> get onTokenRefresh;

  /// Stream of push messages received while app is in foreground.
  Stream<PushIncomingMessage> get onMessage;

  /// Stream of push-tap messages opened from background.
  Stream<PushIncomingMessage> get onMessageOpenedApp;

  /// Returns the current device token, if available.
  Future<String?> getToken();

  /// Returns the push-tap message used to launch the app, if any.
  Future<PushIncomingMessage?> getInitialMessage();

  /// Requests runtime notification permission.
  Future<bool> requestPermission();

  /// Configures in-foreground presentation behavior.
  Future<void> configureForegroundPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  });
}
