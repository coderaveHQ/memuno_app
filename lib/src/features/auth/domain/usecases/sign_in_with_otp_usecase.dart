import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: start an OTP or magic link sign-in flow.
final class SignInWithOtpUsecase {
  /// Creates the usecase.
  const SignInWithOtpUsecase({
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

  /// Executes the OTP sign-in operation.
  ///
  /// Throws a [Failure] if the email is invalid.
  Future<void> call({
    /// Email address to receive the OTP or magic link.
    required String email,

    /// Redirect URL for the magic link.
    required String redirectTo,
  }) {
    // Validate email format before hitting the backend.
    final Failure? emailFailure = _validator.validateEmail(email);
    if (emailFailure != null) {
      throw emailFailure;
    }
    return _authRepository.signInWithOtp(email: email, redirectTo: redirectTo);
  }
}
