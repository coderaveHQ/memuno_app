import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_request_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.friendship_request_list_page_item_user`.
@freezed
sealed class FriendshipRequestListPageItemUserEntity
    with _$FriendshipRequestListPageItemUserEntity {
  /// Creates a friendship-request-list item user entity.
  const factory FriendshipRequestListPageItemUserEntity({
    /// User identifier.
    required String id,

    /// Display name.
    required String name,

    /// Friendship code.
    required String friendshipCode,

    /// User profile creation timestamp.
    required DateTime createdAt,

    /// User profile update timestamp.
    required DateTime updatedAt,
  }) = _FriendshipRequestListPageItemUserEntity;

  const FriendshipRequestListPageItemUserEntity._();
}
