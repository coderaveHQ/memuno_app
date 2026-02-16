import 'package:memuno_app/src/features/auth/data/dto/auth_state_change_dto.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_user_dto.dart';

/// Low-level datasource for auth interactions.
///
/// Implementations should handle transport-specific details (e.g. Supabase)
/// and expose a clean, testable interface to the data layer.
abstract interface class AuthDatasource {
  /// Stream of authentication state changes from the backend.
  Stream<AuthStateChangeDto> onAuthStateChange();

  /// Returns the current authenticated user, if any.
  AuthUserDto? currentUser();

  /// Signs in using email and password.
  Future<void> signInWithPassword({
    /// Email address used to authenticate.
    required String email,

    /// Plaintext password used to authenticate.
    required String password,
  });

  /// Starts an OTP or magic link sign-in flow.
  Future<void> signInWithOtp({
    /// Email address to receive the OTP or magic link.
    required String email,

    /// Redirect URL for the magic link.
    required String redirectTo,
  });

  /// Verifies the sign-in OTP token.
  Future<void> verifySignInOtp({required String email, required String token});

  /// Resends the sign-in OTP token.
  Future<void> resendSignInOtp({
    required String email,
    required String redirectTo,
  });

  /// Executes email/password sign-up.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String redirectTo,
  });

  /// Verifies the sign-up OTP token.
  Future<void> verifySignUpOtp({
    /// Email address associated with the OTP, if required.
    required String email,

    /// OTP or verification token.
    required String token,
  });

  /// Resends a sign-up verification code.
  Future<void> resendSignUpOtp({
    /// Email address to resend the code to.
    required String email,

    /// Redirect URL for the confirmation link.
    required String redirectTo,
  });

  /// Starts an email change flow for the current user.
  Future<void> changeEmail({
    /// New email address to set.
    required String email,

    /// Redirect URL used by email verification links.
    required String redirectTo,
  });

  /// Updates the current user's password.
  Future<void> changePassword({
    /// New password to set.
    required String password,
  });

  /// Deletes the currently signed-in account.
  Future<void> deleteAccount();

  /// Signs out the current user.
  Future<void> signOut();
}
