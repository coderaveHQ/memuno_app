import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Validates and updates the current user's name.
final class UpdateCurrentUserDetailsNameUsecase {
  /// Creates the usecase.
  const UpdateCurrentUserDetailsNameUsecase({
    required UserDetailsRepository repository,
    required Validator validator,
  }) : _repository = repository,
       _validator = validator;

  final UserDetailsRepository _repository;
  final Validator _validator;

  /// Executes the update operation.
  Future<void> call({required String name}) {
    final Failure? nameFailure = _validator.validateName(name);
    if (nameFailure != null) {
      throw nameFailure;
    }

    return _repository.updateCurrentUserDetailsName(name: name);
  }
}
