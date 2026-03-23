import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for listing current recipient targets of one meme.
final class ListMemeRecipientsUsecase {
  const ListMemeRecipientsUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  Future<ListPageEntity<MemeRecipientTargetItemEntity>> call({
    required String memeId,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listMemeRecipients(
      memeId: memeId,
      limit: limit,
      cursor: cursor,
    );
  }
}
