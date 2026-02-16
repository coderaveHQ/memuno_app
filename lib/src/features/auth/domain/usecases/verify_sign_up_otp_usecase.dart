import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: verify an OTP.
///
/// Validates inputs locally before delegating to the repository.
final class VerifySignUpOtpUsecase {
  /// Creates the usecase.
  const VerifySignUpOtpUsecase({
    /// Repository used to perform auth operations.
    required AuthRepository authRepository,

    /// Validator used for local input validation.
    required Validator validator,
  }) : _authRepository = authRepository,
       _validator = validator;

  /// Auth repository used for OTP verification calls.
  final AuthRepository _authRepository;

  /// Validator used for input checks.
  final Validator _validator;

  /// Verifies the OTP.
  ///
  /// Throws a [Failure] if inputs are invalid.
  Future<void> call({
    /// Email address associated with the OTP, if required.
    required String email,

    /// OTP or verification token.
    required String token,
  }) {
    // Validate email format before hitting the backend.
    final Failure? emailFailure = _validator.validateEmail(email);
    if (emailFailure != null) {
      throw emailFailure;
    }
    // Validate OTP format before hitting the backend.
    final Failure? otpFailure = _validator.validateOtp(token);
    if (otpFailure != null) {
      throw otpFailure;
    }
    return _authRepository.verifySignUpOtp(email: email, token: token);
  }
}
