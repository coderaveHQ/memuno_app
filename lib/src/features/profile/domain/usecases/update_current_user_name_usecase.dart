import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';

/// Validates and updates the current user's name.
final class UpdateCurrentUserNameUsecase {
  /// Creates the usecase.
  const UpdateCurrentUserNameUsecase({
    required ProfileRepository repository,
    required Validator validator,
  }) : _repository = repository,
       _validator = validator;

  final ProfileRepository _repository;
  final Validator _validator;

  /// Executes the update operation.
  Future<void> call({required String name}) {
    final Failure? nameFailure = _validator.validateName(name);
    if (nameFailure != null) {
      throw nameFailure;
    }

    return _repository.updateCurrentUserName(name: name);
  }
}
