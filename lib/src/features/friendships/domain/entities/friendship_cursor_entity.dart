import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_cursor_entity.freezed.dart';

/// Cursor payload used by `friendships_list` pagination.
@freezed
sealed class FriendshipCursorEntity with _$FriendshipCursorEntity {
  /// Creates a friendship cursor entity.
  const factory FriendshipCursorEntity({
    /// Last seen friendship creation timestamp.
    required DateTime createdAt,

    /// Stable user identifier used as tie-breaker cursor.
    required String id,
  }) = _FriendshipCursorEntity;

  const FriendshipCursorEntity._();
}
