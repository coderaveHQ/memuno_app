import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';

/// Contract for authentication-related operations.
///
/// Implementations live in the data layer and must map errors to domain failures.
abstract interface class AuthRepository {
  /// Stream of auth state changes.
  Stream<AuthStateEntity> onAuthStateChange();

  /// Returns the current user if signed in.
  AuthUserEntity? currentUser();

  /// Signs in with password.
  Future<void> signInWithPassword({
    /// Email address used to authenticate.
    required String email,

    /// Plaintext password used to authenticate.
    required String password,
  });

  /// Starts a one-time password (OTP) sign-in flow.
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

  /// Verifies an OTP or magic link token.
  Future<void> verifySignUpOtp({
    /// Email address associated with the OTP, if required.
    required String email,

    /// OTP or verification token.
    required String token,
  });

  /// Resends a sign-up verification code.
  Future<void> resendSignUpOtp({
    required String email,
    required String redirectTo,
  });

  /// Starts an email change flow for the current user.
  Future<void> changeEmail({required String email, required String redirectTo});

  /// Updates the current user's password.
  Future<void> changePassword({required String password});

  /// Deletes the currently signed-in account.
  Future<void> deleteAccount();

  /// Signs the user out.
  Future<void> signOut();
}
