import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for listing one group's pending invitations.
final class ListGroupDetailsPendingInvitationsUsecase {
  const ListGroupDetailsPendingInvitationsUsecase({
    required GroupDetailsRepository repository,
  }) : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Loads one pending-invitations page.
  Future<ListPageEntity<GroupPendingInvitationItemEntity>> call({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroupDetailsPendingInvitations(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );
  }
}
