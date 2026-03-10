import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:memuno_app/src/features/push_notifications/application/entities/push_incoming_message.dart';
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
  Stream<PushIncomingMessage> get onMessage {
    return FirebaseMessaging.onMessage.map(_toPushIncomingMessage);
  }

  @override
  Stream<PushIncomingMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp.map(_toPushIncomingMessage);
  }

  @override
  Future<String?> getToken() {
    return _firebaseMessaging.getToken();
  }

  @override
  Future<PushIncomingMessage?> getInitialMessage() async {
    final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();
    if (message == null) {
      return null;
    }
    return _toPushIncomingMessage(message);
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
  Future<void> configureForegroundPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) {
    return _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  PushIncomingMessage _toPushIncomingMessage(RemoteMessage message) {
    final Map<String, String> data = message.data.map(
      (String key, dynamic value) => MapEntry(key, value.toString()),
    );

    final String? notificationImageUrl =
        message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl;

    return PushIncomingMessage(
      data: data,
      title: message.notification?.title,
      body: message.notification?.body,
      imageUrl: notificationImageUrl ?? data['push_image_url'],
    );
  }
}
