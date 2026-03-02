import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/data/gateways/io_push_platform_gateway_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_platform_gateway_provider.g.dart';

/// Provides the platform gateway used by push lifecycle orchestration.
@Riverpod(keepAlive: true)
PushPlatformGateway pushPlatformGateway(Ref ref) {
  return const IoPushPlatformGatewayImpl();
}
