import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friend_user_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_status.dart';

part 'friendship_request_entity.freezed.dart';

/// Domain entity representing a friendship request list item.
@freezed
sealed class FriendshipRequestEntity with _$FriendshipRequestEntity {
  /// Creates a friendship request entity.
  const factory FriendshipRequestEntity({
    /// Surrogate request identifier from `public.friendship_requests.id`.
    required String id,

    /// User data for the other participant in the request.
    required FriendUserEntity user,

    /// Current request status.
    required FriendshipRequestStatus status,

    /// Timestamp when the request was created.
    required DateTime createdAt,

    /// Timestamp when the request was last updated.
    required DateTime updatedAt,

    /// Direction of the request for the current authenticated user.
    required FriendshipRequestDirection direction,
  }) = _FriendshipRequestEntity;

  const FriendshipRequestEntity._();
}
