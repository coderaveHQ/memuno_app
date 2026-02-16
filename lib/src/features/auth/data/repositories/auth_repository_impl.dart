import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_state_change_dto.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_user_dto.dart';
import 'package:memuno_app/src/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Repository implementation for authentication operations.
///
/// This repository orchestrates data sources, maps DTOs to domain entities,
/// and normalizes errors into domain failures.
final class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository.
  const AuthRepositoryImpl({
    /// Datasource used for auth operations.
    required AuthDatasource authDatasource,

    /// Mapper for converting DTOs to domain entities.
    required AuthUserMapper authUserMapper,

    /// Failure mapper used to normalize thrown errors.
    required FailureMapper failureMapper,
  }) : _authDatasource = authDatasource,
       _authUserMapper = authUserMapper,
       _failureMapper = failureMapper;

  /// Datasource used for authentication calls.
  final AuthDatasource _authDatasource;

  /// Mapper used to convert DTOs to domain entities.
  final AuthUserMapper _authUserMapper;

  /// Mapper used to normalize errors into domain failures.
  final FailureMapper _failureMapper;

  @override
  /// Streams authentication state changes from the datasource.
  Stream<AuthStateEntity> onAuthStateChange() async* {
    // Emit the initial state derived from the current user.
    final AuthUserEntity? current = currentUser();
    yield AuthStateEntity.initial(user: current);

    // Forward subsequent state changes from the datasource.
    await for (final AuthStateChangeDto change
        in _authDatasource.onAuthStateChange()) {
      final AuthEvent event = change.event;
      final AuthUserEntity? user = change.user == null
          ? null
          : _authUserMapper.toDomain(change.user!);

      yield AuthStateEntity(event: event, user: user);
    }
  }

  @override
  /// Returns the current authenticated user, if available.
  AuthUserEntity? currentUser() {
    // Read the current user DTO and map it to the domain entity.
    final AuthUserDto? dto = _authDatasource.currentUser();
    if (dto == null) {
      return null;
    }
    return _authUserMapper.toDomain(dto);
  }

  @override
  /// Executes password-based sign-in.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Executes OTP-based sign-in.
  Future<void> signInWithOtp({
    required String email,
    required String redirectTo,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.signInWithOtp(email: email, redirectTo: redirectTo);
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Verifies the sign-in OTP token.
  Future<void> verifySignInOtp({
    required String email,
    required String token,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.verifySignInOtp(email: email, token: token);
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Resends the sign-in OTP token.
  Future<void> resendSignInOtp({
    required String email,
    required String redirectTo,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.resendSignInOtp(
        email: email,
        redirectTo: redirectTo,
      );
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Executes email/password sign-up.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String redirectTo,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        redirectTo: redirectTo,
      );
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Verifies the sign-up OTP token.
  Future<void> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.verifySignUpOtp(email: email, token: token);
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Resends the sign-up OTP token.
  Future<void> resendSignUpOtp({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await _authDatasource.resendSignUpOtp(
        email: email,
        redirectTo: redirectTo,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Executes an email-change request for the signed-in user.
  Future<void> changeEmail({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await _authDatasource.changeEmail(email: email, redirectTo: redirectTo);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Executes a password-change request for the signed-in user.
  Future<void> changePassword({required String password}) async {
    try {
      await _authDatasource.changePassword(password: password);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Executes account deletion for the signed-in user.
  Future<void> deleteAccount() async {
    try {
      await _authDatasource.deleteAccount();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Signs out the current user session.
  Future<void> signOut() async {
    try {
      // Delegate to the datasource; errors are mapped below.
      await _authDatasource.signOut();
    } catch (error) {
      // Normalize errors so callers only handle domain failures.
      throw _failureMapper.map(error);
    }
  }
}
