import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for accepting one incoming group invitation.
final class AcceptGroupInvitationUsecase {
  const AcceptGroupInvitationUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<GroupItemEntity> call({required String invitationId}) {
    return _repository.acceptGroupInvitation(invitationId: invitationId);
  }
}
