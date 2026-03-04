import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_user_entity.dart';

part 'friendship_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.friendship_list_page_item`.
@freezed
sealed class FriendshipListPageItemEntity with _$FriendshipListPageItemEntity {
  /// Creates a friendship-list item entity.
  const factory FriendshipListPageItemEntity({
    /// Nested friend user payload.
    required FriendshipListPageItemUserEntity user,

    /// Friendship creation timestamp.
    required DateTime createdAt,

    /// Friendship update timestamp.
    required DateTime updatedAt,
  }) = _FriendshipListPageItemEntity;

  const FriendshipListPageItemEntity._();
}
