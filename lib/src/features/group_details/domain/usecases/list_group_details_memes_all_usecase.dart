import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for listing all memes sent to one group.
final class ListGroupDetailsMemesAllUsecase {
  const ListGroupDetailsMemesAllUsecase({
    required GroupDetailsRepository repository,
  }) : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Loads one memes page.
  Future<ListPageEntity<MemeItemEntity>> call({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroupDetailsMemesAll(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );
  }
}
