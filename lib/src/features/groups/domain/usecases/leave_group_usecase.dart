import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for leaving one group membership.
final class LeaveGroupUsecase {
  const LeaveGroupUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<void> call({required String groupId}) {
    return _repository.leaveGroup(groupId: groupId);
  }
}
