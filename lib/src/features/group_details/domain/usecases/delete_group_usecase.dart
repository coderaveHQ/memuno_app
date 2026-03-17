import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for deleting one group.
final class DeleteGroupUsecase {
  const DeleteGroupUsecase({required GroupDetailsRepository repository})
    : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Deletes one group.
  Future<void> call({required String groupId}) {
    return _repository.deleteGroup(groupId: groupId);
  }
}
