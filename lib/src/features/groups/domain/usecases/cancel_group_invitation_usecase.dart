import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for canceling one pending group invitation.
final class CancelGroupInvitationUsecase {
  const CancelGroupInvitationUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<void> call({required String invitationId}) {
    return _repository.cancelGroupInvitation(invitationId: invitationId);
  }
}
