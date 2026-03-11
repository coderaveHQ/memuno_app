import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutter_local_notifications_plugin_provider.g.dart';

/// Provides the app-wide [FlutterLocalNotificationsPlugin] instance.
@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) {
  return FlutterLocalNotificationsPlugin();
}
