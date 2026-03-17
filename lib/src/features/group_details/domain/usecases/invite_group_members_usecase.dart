import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for inviting one or more users to a group.
final class InviteGroupMembersUsecase {
  const InviteGroupMembersUsecase({required GroupDetailsRepository repository})
    : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Sends invitations for one group.
  Future<void> call({
    required String groupId,
    required List<String> inviteeUserIds,
  }) {
    return _repository.inviteGroupMembers(
      groupId: groupId,
      inviteeUserIds: inviteeUserIds,
    );
  }
}
