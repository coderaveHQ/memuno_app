import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for listing one group's members.
final class ListGroupDetailsMembersUsecase {
  const ListGroupDetailsMembersUsecase({
    required GroupDetailsRepository repository,
  }) : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Loads one members page.
  Future<ListPageEntity<GroupMemberItemEntity>> call({
    required String groupId,
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroupDetailsMembers(
      groupId: groupId,
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
