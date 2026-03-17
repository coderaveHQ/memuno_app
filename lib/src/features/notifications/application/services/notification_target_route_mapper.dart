import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_navigation_target.dart';

/// Maps notification navigation targets to canonical GoRouter locations.
final class NotificationTargetRouteMapper {
  /// Creates the route mapper.
  const NotificationTargetRouteMapper();

  /// Returns the route location for [target].
  String toLocation(NotificationNavigationTarget target) {
    return switch (target.kind) {
      NotificationNavigationTargetKind.friendships => FriendshipsRoute(
        tab: target.friendshipsTab,
      ).location,
      NotificationNavigationTargetKind.groups => GroupsRoute(
        tab: target.groupsTab,
      ).location,
      NotificationNavigationTargetKind.userDetails => UserDetailsRoute(
        userId: target.userId!,
      ).location,
      NotificationNavigationTargetKind.memeDetails => MemeDetailsRoute(
        memeId: target.memeId!,
      ).location,
      NotificationNavigationTargetKind.notifications =>
        const NotificationsRoute().location,
    };
  }

  /// Returns the canonical notifications inbox location.
  String notificationsLocation() => const NotificationsRoute().location;
}
