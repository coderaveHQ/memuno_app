import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for loading incoming group invitations.
final class ListGroupInvitationsUsecase {
  const ListGroupInvitationsUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<ListPageEntity<GroupInvitationItemEntity>> call({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroupInvitations(
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
