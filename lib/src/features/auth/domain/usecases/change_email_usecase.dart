import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: request an email change for the current user.
final class ChangeEmailUsecase {
  /// Creates the usecase.
  const ChangeEmailUsecase({
    required AuthRepository authRepository,
    required Validator validator,
  }) : _authRepository = authRepository,
       _validator = validator;

  final AuthRepository _authRepository;
  final Validator _validator;

  /// Starts the email change flow.
  Future<void> call({required String email, required String redirectTo}) {
    final Failure? emailFailure = _validator.validateEmail(email);
    if (emailFailure != null) {
      throw emailFailure;
    }
    return _authRepository.changeEmail(email: email, redirectTo: redirectTo);
  }
}
