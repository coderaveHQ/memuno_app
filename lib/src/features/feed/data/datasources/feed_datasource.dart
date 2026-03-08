import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_dto.dart';

/// Low-level datasource for feed RPC calls.
abstract interface class FeedDatasource {
  /// Loads one page of feed items.
  Future<FeedListPageDto> listFeed({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({
    /// Meme id to like/unlike.
    required String memeId,
  });
}
