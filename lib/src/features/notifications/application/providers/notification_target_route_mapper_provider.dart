import 'package:memuno_app/src/features/notifications/application/services/notification_target_route_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_target_route_mapper_provider.g.dart';

/// Provides the notification target-to-route mapper.
@riverpod
NotificationTargetRouteMapper notificationTargetRouteMapper(Ref ref) {
  return const NotificationTargetRouteMapper();
}
