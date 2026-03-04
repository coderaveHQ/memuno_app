import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.friendship_list_page_item_user`.
@freezed
sealed class FriendshipListPageItemUserEntity
    with _$FriendshipListPageItemUserEntity {
  /// Creates a friendship-list item user entity.
  const factory FriendshipListPageItemUserEntity({
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
  }) = _FriendshipListPageItemUserEntity;

  const FriendshipListPageItemUserEntity._();
}
