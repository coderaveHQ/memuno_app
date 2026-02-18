import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friend_user_entity.dart';

part 'friendship_entity.freezed.dart';

/// Domain entity representing an active friendship edge for the current user.
@freezed
sealed class FriendshipEntity with _$FriendshipEntity {
  /// Creates a friendship entity.
  const factory FriendshipEntity({
    /// User data for the friend on the other side of the edge.
    required FriendUserEntity user,

    /// Timestamp when the friendship edge was created.
    required DateTime createdAt,

    /// Timestamp when the friendship edge was last updated.
    required DateTime updatedAt,
  }) = _FriendshipEntity;

  const FriendshipEntity._();
}
