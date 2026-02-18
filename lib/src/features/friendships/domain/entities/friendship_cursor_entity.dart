import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_cursor_entity.freezed.dart';

/// Cursor payload used by `friendships_list` pagination.
@freezed
sealed class FriendshipCursorEntity with _$FriendshipCursorEntity {
  /// Creates a friendship cursor entity.
  const factory FriendshipCursorEntity({
    /// Last seen lowercase name used for lexicographic pagination.
    required String name,

    /// Stable user identifier used as tie-breaker cursor.
    required String id,
  }) = _FriendshipCursorEntity;

  const FriendshipCursorEntity._();
}
