import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';

/// Repository contract for meme details and laughs operations.
abstract interface class MemeDetailsRepository {
  /// Loads meme details for one [memeId].
  Future<MemeDetailsEntity> getMemeDetails({
    /// Meme id to load.
    required String memeId,
  });

  /// Loads one paginated page of meme laughs for [memeId].
  Future<MemeLaughListPageEntity> listMemeLaughs({
    /// Meme id to query laughs for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    MemeLaughCursorEntity? cursor,
  });

  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({
    /// Meme id to like/unlike.
    required String memeId,
  });

  /// Deletes one meme owned by the current user.
  Future<void> deleteMeme({
    /// Meme id to delete.
    required String memeId,
  });
}
