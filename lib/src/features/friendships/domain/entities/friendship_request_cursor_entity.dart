import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_request_cursor_entity.freezed.dart';

/// Cursor payload used by `friendship_requests_list` pagination.
@freezed
sealed class FriendshipRequestCursorEntity
    with _$FriendshipRequestCursorEntity {
  /// Creates a friendship request cursor entity.
  const factory FriendshipRequestCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable request identifier used as tie-breaker cursor.
    required String id,
  }) = _FriendshipRequestCursorEntity;

  const FriendshipRequestCursorEntity._();
}
