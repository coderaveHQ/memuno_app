import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';

/// Low-level datasource for meme details RPC calls.
abstract interface class MemeDetailsDatasource {
  /// Loads details payload for one meme.
  Future<MemeDetailsDto> getMemeDetails({
    /// Meme id to load.
    required String memeId,
  });

  /// Loads one page of laughed users for one meme.
  Future<MemeLaughListPageDto> listMemeLaughs({
    /// Meme id to query laughs for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id value for subsequent page fetches.
    String? cursorId,
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
