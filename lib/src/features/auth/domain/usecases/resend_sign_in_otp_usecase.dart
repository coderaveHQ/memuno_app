import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: resend a sign-in OTP.
final class ResendSignInOtpUsecase {
  /// Creates the usecase.
  const ResendSignInOtpUsecase({
    /// Repository used to perform auth operations.
    required AuthRepository authRepository,

    /// Validator used for local input validation.
    required Validator validator,
  }) : _authRepository = authRepository,
       _validator = validator;

  /// Auth repository used for resend calls.
  final AuthRepository _authRepository;

  /// Validator used for input checks.
  final Validator _validator;

  /// Resends the sign-in OTP.
  ///
  /// Throws a [Failure] if the email is invalid.
  Future<void> call({
    /// Email address to receive the OTP.
    required String email,

    /// Redirect URL for the confirmation link.
    required String redirectTo,
  }) {
    final Failure? emailFailure = _validator.validateEmail(email);
    if (emailFailure != null) {
      throw emailFailure;
    }
    return _authRepository.resendSignInOtp(
      email: email,
      redirectTo: redirectTo,
    );
  }
}
