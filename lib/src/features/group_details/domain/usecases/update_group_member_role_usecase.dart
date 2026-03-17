import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for updating one group member role.
final class UpdateGroupMemberRoleUsecase {
  const UpdateGroupMemberRoleUsecase({
    required GroupDetailsRepository repository,
  }) : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Updates one group-member role.
  Future<void> call({
    required String groupId,
    required String userId,
    required GroupUserType type,
  }) {
    return _repository.updateGroupMemberRole(
      groupId: groupId,
      userId: userId,
      type: type,
    );
  }
}
