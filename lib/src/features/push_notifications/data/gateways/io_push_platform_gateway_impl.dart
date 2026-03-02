import 'dart:io';

import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';

/// `dart:io` implementation of [PushPlatformGateway].
final class IoPushPlatformGatewayImpl implements PushPlatformGateway {
  /// Creates the gateway.
  const IoPushPlatformGatewayImpl();

  @override
  bool get supportsPushNotifications => Platform.isAndroid || Platform.isIOS;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  PushPlatform? resolvePushPlatform() {
    if (Platform.isIOS) {
      return PushPlatform.ios;
    }
    if (Platform.isAndroid) {
      return PushPlatform.android;
    }
    return null;
  }
}
