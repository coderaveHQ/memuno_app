import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_dto.dart';

/// Low-level datasource for friendships and friendship-request RPC calls.
abstract interface class FriendshipsDatasource {
  /// Loads one page of friendships.
  Future<FriendshipListPageDto> listFriendships({
    /// Optional search term applied server-side.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor name for subsequent page fetches.
    String? cursorName,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page of friendship requests.
  Future<FriendshipRequestListPageDto> listFriendshipRequests({
    /// Optional search term applied server-side.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Creates a new friendship request by addressee friendship code.
  Future<FriendshipRequestListPageItemDto> createFriendshipRequest({
    /// Friendship code entered by the requester.
    required String addresseeFriendshipCode,
  });

  /// Accepts an incoming friendship request.
  Future<FriendshipListPageItemDto> acceptFriendshipRequest({
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

  /// Deletes an active friendship.
  Future<void> deleteFriendship({
    /// Friend id to remove from the current user's friendships.
    required String friendId,
  });
}
