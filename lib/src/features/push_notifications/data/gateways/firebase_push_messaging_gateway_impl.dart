import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';

/// Firebase Messaging implementation of [PushMessagingGateway].
final class FirebasePushMessagingGatewayImpl implements PushMessagingGateway {
  /// Creates the gateway.
  const FirebasePushMessagingGatewayImpl({
    required FirebaseMessaging firebaseMessaging,
  }) : _firebaseMessaging = firebaseMessaging;

  final FirebaseMessaging _firebaseMessaging;

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Future<String?> getToken() {
    return _firebaseMessaging.getToken();
  }

  @override
  Future<bool> requestPermission() async {
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(alert: true, badge: true, sound: true);
    final AuthorizationStatus status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  @override
  Future<void> configureForegroundPresentationOptions() {
    return _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
