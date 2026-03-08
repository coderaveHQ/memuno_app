import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_entity.dart';
import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';

/// Usecase for loading paginated feed items.
final class ListFeedUsecase {
  /// Creates the usecase.
  const ListFeedUsecase({required FeedRepository repository})
    : _repository = repository;

  final FeedRepository _repository;

  /// Executes a paginated feed query.
  Future<FeedListPageEntity> call({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FeedCursorEntity? cursor,
  }) {
    return _repository.listFeed(limit: limit, cursor: cursor);
  }
}
