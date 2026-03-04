import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';

/// Repository contract for friendship and friendship-request operations.
abstract interface class FriendshipsRepository {
  /// Loads one friendship-list page.
  Future<FriendshipListPageEntity> listFriendships({
    /// Optional search term applied to friend name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipCursorEntity? cursor,
  });

  /// Loads one friendship-request-list page.
  Future<FriendshipRequestListPageEntity> listFriendshipRequests({
    /// Optional search term applied to name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipRequestCursorEntity? cursor,
  });

  /// Creates a pending friendship request targeting a friendship code.
  Future<FriendshipRequestListPageItemEntity> createFriendshipRequest({
    /// Friendship code entered by the requester.
    required String addresseeFriendshipCode,
  });

  /// Accepts an incoming friendship request and returns the created friendship.
  Future<FriendshipListPageItemEntity> acceptFriendshipRequest({
    /// Pending friendship-request row identifier.
    required String requestId,
  });

  /// Declines an incoming friendship request.
  Future<void> declineFriendshipRequest({
    /// Pending friendship-request row identifier.
    required String requestId,
  });

  /// Cancels an outgoing friendship request.
  Future<void> cancelFriendshipRequest({
    /// Pending friendship-request row identifier.
    required String requestId,
  });

  /// Deletes an existing friendship edge for both users.
  Future<void> deleteFriendship({
    /// Friend user id to unfriend.
    required String friendId,
  });
}
