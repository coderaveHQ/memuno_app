import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for removing one user from a group.
final class RemoveGroupMemberUsecase {
  const RemoveGroupMemberUsecase({required GroupDetailsRepository repository})
    : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Removes one user from one group.
  Future<void> call({required String groupId, required String userId}) {
    return _repository.removeGroupMember(groupId: groupId, userId: userId);
  }
}
