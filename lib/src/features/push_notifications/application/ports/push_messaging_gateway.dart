/// Port for push-messaging SDK interactions.
abstract interface class PushMessagingGateway {
  /// Stream of refreshed device tokens.
  Stream<String> get onTokenRefresh;

  /// Returns the current device token, if available.
  Future<String?> getToken();

  /// Requests runtime notification permission.
  Future<bool> requestPermission();

  /// Configures in-foreground presentation behavior.
  Future<void> configureForegroundPresentationOptions();
}
