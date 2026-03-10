import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/app_badge_gateway.dart';

/// `app_badge_plus` implementation of [AppBadgeGateway].
final class FlutterAppBadgeGatewayImpl implements AppBadgeGateway {
  /// Creates the gateway.
  const FlutterAppBadgeGatewayImpl();

  @override
  Future<void> setBadgeCount(int count) async {
    final bool isSupported = await AppBadgePlus.isSupported();
    if (!isSupported) {
      return;
    }

    if (count <= 0) {
      await AppBadgePlus.updateBadge(0);
      return;
    }

    await AppBadgePlus.updateBadge(count);
  }

  @override
  Future<void> clearBadge() async {
    final bool isSupported = await AppBadgePlus.isSupported();
    if (!isSupported) {
      return;
    }

    await AppBadgePlus.updateBadge(0);
  }
}
