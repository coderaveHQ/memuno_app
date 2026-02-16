import 'package:memuno_app/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_state_change_dto.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_user_dto.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [AuthDatasource].
final class SupabaseAuthDatasourceImpl implements AuthDatasource {
  /// Creates the datasource.
  const SupabaseAuthDatasourceImpl({
    /// Supabase client used for auth operations.
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Supabase client used for all auth calls.
  final SupabaseClient _supabaseClient;

  @override
  /// Streams authentication state changes from the datasource.
  Stream<AuthStateChangeDto> onAuthStateChange() {
    // Convert Supabase auth state changes into DTOs.
    return _supabaseClient.auth.onAuthStateChange.map((AuthState state) {
      final User? user = state.session?.user;
      final AuthUserDto? dto = user == null
          ? null
          : AuthUserDto.fromSupabase(user);
      final AuthEvent event = _mapEvent(state.event);
      return AuthStateChangeDto(event: event, user: dto);
    });
  }

  @override
  /// Returns the current authenticated user, if available.
  AuthUserDto? currentUser() {
    // Read the current user from Supabase auth.
    final User? user = _supabaseClient.auth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUserDto.fromSupabase(user);
  }

  @override
  /// Executes password-based sign-in.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    // Supabase throws on error; callers handle exceptions.
    final AuthResponse _ = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  /// Executes OTP-based sign-in.
  Future<void> signInWithOtp({
    required String email,
    required String redirectTo,
  }) async {
    // Send OTP or magic link to the given email.
    await _supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
      emailRedirectTo: redirectTo,
    );
  }

  @override
  /// Verifies the sign-in OTP token.
  Future<void> verifySignInOtp({
    required String email,
    required String token,
  }) async {
    // Supabase throws on error; callers handle exceptions.
    final AuthResponse _ = await _supabaseClient.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.magiclink,
    );
  }

  @override
  /// Resends the sign-in OTP token.
  Future<void> resendSignInOtp({
    required String email,
    required String redirectTo,
  }) async {
    await _supabaseClient.auth.resend(
      email: email,
      type: OtpType.magiclink,
      emailRedirectTo: redirectTo,
    );
  }

  @override
  /// Executes email/password sign-up.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String redirectTo,
  }) async {
    await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'initial_data': <String, dynamic>{'name': name},
      },
      emailRedirectTo: redirectTo,
    );
  }

  @override
  /// Verifies the sign-up OTP token.
  Future<void> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    // Supabase throws on error; callers handle exceptions.
    final AuthResponse _ = await _supabaseClient.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  @override
  /// Resends the sign-up OTP token.
  Future<void> resendSignUpOtp({
    required String email,
    required String redirectTo,
  }) async {
    await _supabaseClient.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: redirectTo,
    );
  }

  @override
  /// Executes an email-change request for the signed-in user.
  Future<void> changeEmail({
    required String email,
    required String redirectTo,
  }) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(email: email),
      emailRedirectTo: redirectTo,
    );
  }

  @override
  /// Executes a password-change request for the signed-in user.
  Future<void> changePassword({required String password}) async {
    await _supabaseClient.auth.updateUser(UserAttributes(password: password));
  }

  @override
  /// Executes account deletion for the signed-in user.
  Future<void> deleteAccount() async {
    await _supabaseClient.functions.invoke('delete-own-account');
    await _supabaseClient.auth.signOut();
  }

  @override
  /// Signs out the current user session.
  Future<void> signOut() async {
    // Sign out the current session.
    await _supabaseClient.auth.signOut();
  }

  /// Maps Supabase auth events to domain events.
  AuthEvent _mapEvent(AuthChangeEvent event) {
    return switch (event) {
      AuthChangeEvent.initialSession => AuthEvent.initial,
      AuthChangeEvent.signedIn => AuthEvent.signedIn,
      AuthChangeEvent.signedOut => AuthEvent.signedOut,
      AuthChangeEvent.tokenRefreshed => AuthEvent.tokenRefreshed,
      AuthChangeEvent.userUpdated => AuthEvent.userUpdated,
      AuthChangeEvent.passwordRecovery => AuthEvent.passwordRecovery,
      _ => AuthEvent.unknown,
    };
  }
}
