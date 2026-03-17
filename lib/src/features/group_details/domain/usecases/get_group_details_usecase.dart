import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for loading one group-details payload.
final class GetGroupDetailsUsecase {
  const GetGroupDetailsUsecase({required GroupDetailsRepository repository})
    : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Loads one group-details payload.
  Future<GroupDetailsEntity> call({required String groupId}) {
    return _repository.getGroupDetails(groupId: groupId);
  }
}
