import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_list_page_item_data_entity.freezed.dart';

/// Strongly typed domain hierarchy for `public.notifications.data`.
@freezed
sealed class NotificationListPageItemDataEntity
    with _$NotificationListPageItemDataEntity {
  /// Data payload for `friendship_request_sent`.
  const factory NotificationListPageItemDataEntity.friendshipRequestSent({
    required String actorId,
    required String actorName,
    required String actorFriendshipCode,
    required String requestId,
    required String routeTab,
  }) = FriendshipRequestSentNotificationListPageItemDataEntity;

  /// Data payload for `friendship_request_accepted`.
  const factory NotificationListPageItemDataEntity.friendshipRequestAccepted({
    required String actorId,
    required String actorName,
    required String actorFriendshipCode,
    required String requestId,
    required String routeTab,
  }) = FriendshipRequestAcceptedNotificationListPageItemDataEntity;

  /// Data payload for `group_invitation_sent`.
  const factory NotificationListPageItemDataEntity.groupInvitationSent({
    required String actorId,
    required String actorName,
    required String actorFriendshipCode,
    required String invitationId,
    required String groupId,
    required String groupName,
    required String routeTab,
  }) = GroupInvitationSentNotificationListPageItemDataEntity;

  /// Data payload for `meme_received`.
  const factory NotificationListPageItemDataEntity.memeReceived({
    /// Actor user id of the meme sender.
    required String actorId,

    /// Actor display name of the meme sender.
    required String actorName,

    /// Meme id from `public.memes.id`.
    required String memeId,

    /// Storage path from `public.memes.push_image_path`.
    required String? memePushImagePath,

    /// Persisted aspect ratio (`width / height`) from `public.memes`.
    required double memeAspectRatio,

    /// Optional recipient target group id for group-targeted meme notifications.
    required String? groupId,

    /// Optional recipient target group name for group-targeted meme notifications.
    required String? groupName,

    /// Frontend-signed URL for rendering private meme image previews.
    required String? signedMemeImageUrl,

    /// Optional deep-link route tab (currently always null for memes).
    required String? routeTab,
  }) = MemeReceivedNotificationListPageItemDataEntity;

  /// Data payload for `meme_laughed`.
  const factory NotificationListPageItemDataEntity.memeLaughed({
    /// Actor user id of the user who laughed at the meme.
    required String actorId,

    /// Actor display name of the user who laughed at the meme.
    required String actorName,

    /// Meme id from `public.memes.id`.
    required String memeId,

    /// Storage path from `public.memes.push_image_path`.
    required String? memePushImagePath,

    /// Persisted aspect ratio (`width / height`) from `public.memes`.
    required double memeAspectRatio,

    /// Frontend-signed URL for rendering private meme image previews.
    required String? signedMemeImageUrl,

    /// Optional deep-link route tab (currently always null for laughs).
    required String? routeTab,
  }) = MemeLaughedNotificationListPageItemDataEntity;
}
