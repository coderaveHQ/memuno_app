import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_status.dart';

part 'friendship_request_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.friendship_request_list_page_item`.
@freezed
sealed class FriendshipRequestListPageItemEntity
    with _$FriendshipRequestListPageItemEntity {
  /// Creates a friendship-request-list item entity.
  const factory FriendshipRequestListPageItemEntity({
    /// Request identifier.
    required String id,

    /// Request status.
    required FriendshipRequestStatus status,

    /// Request creation timestamp.
    required DateTime createdAt,

    /// Request update timestamp.
    required DateTime updatedAt,

    /// Direction relative to current user.
    required FriendshipRequestDirection direction,

    /// Nested counterpart user payload.
    required FriendshipRequestListPageItemUserEntity user,
  }) = _FriendshipRequestListPageItemEntity;

  const FriendshipRequestListPageItemEntity._();
}
