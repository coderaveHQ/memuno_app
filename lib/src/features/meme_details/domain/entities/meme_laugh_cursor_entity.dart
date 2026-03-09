import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_laugh_cursor_entity.freezed.dart';

/// Cursor payload used by `meme_laughs_list` pagination.
@freezed
sealed class MemeLaughCursorEntity with _$MemeLaughCursorEntity {
  /// Creates one meme-laugh cursor entity.
  const factory MemeLaughCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable user id used as tie-breaker cursor.
    required String userId,
  }) = _MemeLaughCursorEntity;

  const MemeLaughCursorEntity._();
}
