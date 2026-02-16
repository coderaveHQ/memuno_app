import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: change the current user's password.
final class ChangePasswordUsecase {
  /// Creates the usecase.
  const ChangePasswordUsecase({
    required AuthRepository authRepository,
    required Validator validator,
  }) : _authRepository = authRepository,
       _validator = validator;

  final AuthRepository _authRepository;
  final Validator _validator;

  /// Updates the password.
  Future<void> call({required String password}) {
    final Failure? passwordFailure = _validator.validatePassword(password);
    if (passwordFailure != null) {
      throw passwordFailure;
    }
    return _authRepository.changePassword(password: password);
  }
}
