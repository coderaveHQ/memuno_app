import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_local_notifications_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/data/gateways/flutter_push_local_notifications_gateway_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_local_notifications_gateway_provider.g.dart';

/// Provides foreground local-notification gateway.
@Riverpod(keepAlive: true)
PushLocalNotificationsGateway pushLocalNotificationsGateway(Ref ref) {
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  return FlutterPushLocalNotificationsGatewayImpl(
    localNotificationsPlugin: plugin,
  );
}
