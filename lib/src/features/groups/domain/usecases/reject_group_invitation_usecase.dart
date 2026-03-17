import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for rejecting one incoming group invitation.
final class RejectGroupInvitationUsecase {
  const RejectGroupInvitationUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<void> call({required String invitationId}) {
    return _repository.rejectGroupInvitation(invitationId: invitationId);
  }
}
