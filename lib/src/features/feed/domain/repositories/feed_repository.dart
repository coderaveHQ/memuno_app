import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_entity.dart';

/// Repository contract for feed list operations.
abstract interface class FeedRepository {
  /// Loads one paginated feed page.
  Future<FeedListPageEntity> listFeed({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FeedCursorEntity? cursor,
  });

  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({
    /// Meme id to like/unlike.
    required String memeId,
  });
}
