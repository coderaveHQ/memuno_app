import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';

/// Repository contract for friendship and friendship-request operations.
abstract interface class FriendshipsRepository {
  /// Loads one paginated friendships page.
  Future<PaginatedPage<FriendshipEntity, FriendshipCursorEntity>>
  listFriendships({
    /// Optional search term applied to friend name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipCursorEntity? cursor,
  });

  /// Loads one paginated friendship-requests page.
  Future<PaginatedPage<FriendshipRequestEntity, FriendshipRequestCursorEntity>>
  listFriendshipRequests({
    /// Optional search term applied to name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipRequestCursorEntity? cursor,
  });

  /// Creates a pending friendship request targeting a friendship code.
  Future<FriendshipRequestEntity> createFriendshipRequest({
    /// Friendship code entered by the requester.
    required String addresseeFriendshipCode,
  });

  /// Accepts an incoming friendship request and returns the created friendship.
  Future<FriendshipEntity> acceptFriendshipRequest({
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
