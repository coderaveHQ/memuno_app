import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for listing addable recipient targets of one owned meme.
final class ListMemeAddableRecipientTargetsUsecase {
  const ListMemeAddableRecipientTargetsUsecase({
    required MemeDetailsRepository repository,
  }) : _repository = repository;

  final MemeDetailsRepository _repository;

  Future<ListPageEntity<MemeRecipientTargetItemEntity>> call({
    required String memeId,
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listMemeAddableRecipientTargets(
      memeId: memeId,
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
