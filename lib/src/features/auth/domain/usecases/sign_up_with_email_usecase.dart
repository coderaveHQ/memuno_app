import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

final class SignUpWithEmailUsecase {
  /// Creates the usecase.
  const SignUpWithEmailUsecase({
    /// Repository used to perform auth operations.
    required AuthRepository authRepository,

    /// Validator used for local input validation.
    required Validator validator,
  }) : _authRepository = authRepository,
       _validator = validator;

  /// Auth repository used for sign-in calls.
  final AuthRepository _authRepository;

  /// Validator used for input checks.
  final Validator _validator;

  /// Executes the sign-in operation.
  ///
  /// Throws a [Failure] if inputs are invalid.
  Future<void> call({
    required String name,

    /// Email address used to authenticate.
    required String email,

    /// Plaintext password used to authenticate.
    required String password,

    /// Redirect URL for the magic link.
    required String redirectTo,
  }) {
    // Validate email format before hitting the backend.
    final Failure? nameFailure = _validator.validateName(name);
    if (nameFailure != null) {
      throw nameFailure;
    }
    // Validate email format before hitting the backend.
    final Failure? emailFailure = _validator.validateEmail(email);
    if (emailFailure != null) {
      throw emailFailure;
    }
    // Validate password length before hitting the backend.
    final Failure? passwordFailure = _validator.validatePassword(password);
    if (passwordFailure != null) {
      throw passwordFailure;
    }
    return _authRepository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      redirectTo: redirectTo,
    );
  }
}
