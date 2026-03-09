import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for loading paginated laughs of one meme.
final class ListMemeLaughsUsecase {
  /// Creates the usecase.
  const ListMemeLaughsUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  /// Executes a paginated meme-laugh query.
  Future<MemeLaughListPageEntity> call({
    /// Meme id to query laughs for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    MemeLaughCursorEntity? cursor,
  }) {
    return _repository.listMemeLaughs(
      memeId: memeId,
      limit: limit,
      cursor: cursor,
    );
  }
}
