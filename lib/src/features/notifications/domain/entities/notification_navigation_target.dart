/// Resolved in-app navigation targets for notifications.
enum NotificationNavigationTargetKind {
  /// Opens friendships page.
  friendships,

  /// Opens a user details page.
  userDetails,

  /// Opens meme details page.
  memeDetails,

  /// Opens notifications inbox page.
  notifications,
}

/// Navigation target resolved from notification payloads.
final class NotificationNavigationTarget {
  const NotificationNavigationTarget._({
    required this.kind,
    this.friendshipsTab,
    this.userId,
    this.memeId,
  });

  /// Target kind.
  final NotificationNavigationTargetKind kind;

  /// Optional friendships tab route value (`friendships` or `requests`).
  final String? friendshipsTab;

  /// Optional user id for user-details destinations.
  final String? userId;

  /// Optional meme id for meme-details destinations.
  final String? memeId;

  /// Creates a friendships target.
  factory NotificationNavigationTarget.friendships({required String tab}) {
    return NotificationNavigationTarget._(
      kind: NotificationNavigationTargetKind.friendships,
      friendshipsTab: tab,
    );
  }

  /// Creates a user-details target.
  factory NotificationNavigationTarget.userDetails({required String userId}) {
    return NotificationNavigationTarget._(
      kind: NotificationNavigationTargetKind.userDetails,
      userId: userId,
    );
  }

  /// Creates a meme-details target.
  factory NotificationNavigationTarget.memeDetails({required String memeId}) {
    return NotificationNavigationTarget._(
      kind: NotificationNavigationTargetKind.memeDetails,
      memeId: memeId,
    );
  }

  /// Creates a notifications inbox target.
  factory NotificationNavigationTarget.notifications() {
    return const NotificationNavigationTarget._(
      kind: NotificationNavigationTargetKind.notifications,
    );
  }
}

/// Push-intent payload resolved from notification push data.
final class NotificationPushIntent {
  /// Creates one push intent.
  const NotificationPushIntent({
    required this.notificationId,
    required this.target,
  });

  /// Notification id carried in push payload, when available.
  final String? notificationId;

  /// Resolved navigation target.
  final NotificationNavigationTarget target;
}
