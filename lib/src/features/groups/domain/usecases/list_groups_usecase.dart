import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for loading paginated groups.
final class ListGroupsUsecase {
  const ListGroupsUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<ListPageEntity<GroupItemEntity>> call({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroups(search: search, limit: limit, cursor: cursor);
  }
}
