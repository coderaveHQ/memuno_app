import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Validates and updates one group name.
final class UpdateGroupNameUsecase {
  const UpdateGroupNameUsecase({
    required GroupDetailsRepository repository,
    required Validator validator,
  }) : _repository = repository,
       _validator = validator;

  final GroupDetailsRepository _repository;
  final Validator _validator;

  /// Executes the group-name update operation.
  Future<void> call({required String groupId, required String name}) {
    final String trimmedName = name.trim();
    final Failure? nameFailure = _validator.validateName(trimmedName);
    if (nameFailure != null) {
      throw nameFailure;
    }

    return _repository.updateGroupName(groupId: groupId, name: trimmedName);
  }
}
