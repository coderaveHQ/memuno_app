import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_cursor_entity.freezed.dart';

/// Cursor payload used by `feed_list` pagination.
@freezed
sealed class FeedCursorEntity with _$FeedCursorEntity {
  /// Creates a feed cursor entity.
  const factory FeedCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable meme id used as a tie-breaker cursor.
    required String id,
  }) = _FeedCursorEntity;

  const FeedCursorEntity._();
}
