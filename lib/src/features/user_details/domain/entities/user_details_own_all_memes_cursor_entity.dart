import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_all_memes_cursor_entity.freezed.dart';

/// Cursor payload used by `user_details_own_all_memes_list` pagination.
@freezed
sealed class UserDetailsOwnAllMemesCursorEntity
    with _$UserDetailsOwnAllMemesCursorEntity {
  /// Creates one own-all memes cursor entity.
  const factory UserDetailsOwnAllMemesCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable meme id used as tie-breaker cursor.
    required String id,
  }) = _UserDetailsOwnAllMemesCursorEntity;

  const UserDetailsOwnAllMemesCursorEntity._();
}
