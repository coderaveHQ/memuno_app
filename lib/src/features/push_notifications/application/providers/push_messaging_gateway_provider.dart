import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/data/gateways/firebase_push_messaging_gateway_impl.dart';
import 'package:memuno_app/src/infrastructure/firebase/firebase_messaging_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_messaging_gateway_provider.g.dart';

/// Provides the push-messaging gateway.
@Riverpod(keepAlive: true)
PushMessagingGateway pushMessagingGateway(Ref ref) {
  final FirebaseMessaging firebaseMessaging = ref.watch(
    firebaseMessagingProvider,
  );
  return FirebasePushMessagingGatewayImpl(firebaseMessaging: firebaseMessaging);
}
