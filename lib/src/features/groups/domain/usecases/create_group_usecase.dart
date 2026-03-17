import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Usecase for creating one group and invitations.
final class CreateGroupUsecase {
  const CreateGroupUsecase({required GroupsRepository repository})
    : _repository = repository;

  final GroupsRepository _repository;

  Future<GroupItemEntity> call({
    required String name,
    required List<String> inviteeUserIds,
  }) {
    return _repository.createGroup(name: name, inviteeUserIds: inviteeUserIds);
  }
}
