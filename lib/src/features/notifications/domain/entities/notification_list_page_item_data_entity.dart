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

  /// Data payload for `meme_received`.
  const factory NotificationListPageItemDataEntity.memeReceived({
    required String actorId,
    required String actorName,
    required String memeId,
    required String? routeTab,
  }) = MemeReceivedNotificationListPageItemDataEntity;
}
