import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_data_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_navigation_target.dart';

/// Resolves navigation targets from notification entities and push payloads.
final class ResolveNotificationPushIntentUsecase {
  /// Creates the resolver.
  const ResolveNotificationPushIntentUsecase();

  /// Resolves a navigation target from a notifications list item.
  NotificationNavigationTarget fromNotification(
    NotificationListPageItemEntity notification,
  ) {
    return switch (notification.data) {
      FriendshipRequestSentNotificationListPageItemDataEntity(
        :final routeTab,
      ) =>
        NotificationNavigationTarget.friendships(tab: routeTab),
      FriendshipRequestAcceptedNotificationListPageItemDataEntity(
        :final actorId,
      ) =>
        NotificationNavigationTarget.userDetails(userId: actorId),
      MemeReceivedNotificationListPageItemDataEntity(:final memeId) =>
        NotificationNavigationTarget.memeDetails(memeId: memeId),
      MemeLaughedNotificationListPageItemDataEntity(:final memeId) =>
        NotificationNavigationTarget.memeDetails(memeId: memeId),
    };
  }

  /// Resolves one push intent from an FCM data payload.
  ///
  /// Unknown or malformed payloads fall back to notifications inbox.
  NotificationPushIntent fromPushData(Map<String, String> data) {
    final String? notificationType = _readTrimmed(data, 'notification_type');

    final NotificationNavigationTarget target = switch (notificationType) {
      'friendship_request_sent' => NotificationNavigationTarget.friendships(
        tab: _normalizeFriendshipsTab(
          _readTrimmed(data, 'route_tab') ?? 'requests',
        ),
      ),
      'friendship_request_accepted' => _resolveUserTarget(data),
      'meme_received' => _resolveMemeTarget(data),
      'meme_laughed' => _resolveMemeTarget(data),
      _ => NotificationNavigationTarget.notifications(),
    };

    return NotificationPushIntent(
      notificationId: _readTrimmed(data, 'notification_id'),
      target: target,
    );
  }

  NotificationNavigationTarget _resolveUserTarget(Map<String, String> data) {
    final String? userId = _readTrimmed(data, 'actor_id');
    if (userId == null) {
      return NotificationNavigationTarget.notifications();
    }
    return NotificationNavigationTarget.userDetails(userId: userId);
  }

  NotificationNavigationTarget _resolveMemeTarget(Map<String, String> data) {
    final String? memeId = _readTrimmed(data, 'meme_id');
    if (memeId == null) {
      return NotificationNavigationTarget.notifications();
    }
    return NotificationNavigationTarget.memeDetails(memeId: memeId);
  }

  String _normalizeFriendshipsTab(String rawValue) {
    return rawValue == 'friendships' ? 'friendships' : 'requests';
  }

  String? _readTrimmed(Map<String, String> data, String key) {
    final String? rawValue = data[key];
    if (rawValue == null) {
      return null;
    }

    final String trimmed = rawValue.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
