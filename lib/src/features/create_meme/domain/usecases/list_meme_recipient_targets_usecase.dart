import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_recipient_targets_repository.dart';

/// Usecase for listing polymorphic recipient targets for send-meme flow.
final class ListMemeRecipientTargetsUsecase {
  const ListMemeRecipientTargetsUsecase({
    required MemeRecipientTargetsRepository repository,
  }) : _repository = repository;

  final MemeRecipientTargetsRepository _repository;

  Future<ListPageEntity<MemeRecipientTargetItemEntity>> call({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listRecipientTargets(
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
