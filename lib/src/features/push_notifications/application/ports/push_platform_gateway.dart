import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';

/// Port for platform capabilities used by push lifecycle orchestration.
abstract interface class PushPlatformGateway {
  /// Whether the current runtime supports push notifications.
  bool get supportsPushNotifications;

  /// Whether the current runtime is iOS.
  bool get isIOS;

  /// Resolves the push platform for the current runtime.
  PushPlatform? resolvePushPlatform();
}
