import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_received_memes_cursor_entity.freezed.dart';

/// Cursor payload used by `user_details_own_received_memes_list` pagination.
@freezed
sealed class UserDetailsOwnReceivedMemesCursorEntity
    with _$UserDetailsOwnReceivedMemesCursorEntity {
  /// Creates one own-received memes cursor entity.
  const factory UserDetailsOwnReceivedMemesCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable meme id used as tie-breaker cursor.
    required String id,
  }) = _UserDetailsOwnReceivedMemesCursorEntity;

  const UserDetailsOwnReceivedMemesCursorEntity._();
}
