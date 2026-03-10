import 'package:memuno_app/src/features/push_notifications/application/ports/app_badge_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/data/gateways/flutter_app_badge_gateway_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_badge_gateway_provider.g.dart';

/// Provides the app badge gateway.
@Riverpod(keepAlive: true)
AppBadgeGateway appBadgeGateway(Ref ref) {
  return const FlutterAppBadgeGatewayImpl();
}
