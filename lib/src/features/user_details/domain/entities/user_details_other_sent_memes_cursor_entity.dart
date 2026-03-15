import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_other_sent_memes_cursor_entity.freezed.dart';

/// Cursor payload used by `user_details_other_sent_memes_list` pagination.
@freezed
sealed class UserDetailsOtherSentMemesCursorEntity
    with _$UserDetailsOtherSentMemesCursorEntity {
  /// Creates one other-sent memes cursor entity.
  const factory UserDetailsOtherSentMemesCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable meme id used as tie-breaker cursor.
    required String id,
  }) = _UserDetailsOtherSentMemesCursorEntity;

  const UserDetailsOtherSentMemesCursorEntity._();
}
