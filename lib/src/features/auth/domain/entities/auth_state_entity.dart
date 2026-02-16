import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';

part 'auth_state_entity.freezed.dart';

/// Auth lifecycle events emitted by the backend.
enum AuthEvent {
  /// Initial state emitted on startup.
  initial,

  /// User signed in.
  signedIn,

  /// User signed out.
  signedOut,

  /// User profile updated.
  userUpdated,

  /// Session token refreshed.
  tokenRefreshed,

  /// Password recovery flow started.
  passwordRecovery,

  /// Fallback for unknown events.
  unknown,
}

/// Immutable snapshot of the current authentication state.
///
/// This entity is emitted by domain usecases and consumed by the UI.
@freezed
sealed class AuthStateEntity with _$AuthStateEntity {
  /// Creates an auth state snapshot.
  const factory AuthStateEntity({
    /// Lifecycle event emitted by the auth backend.
    required AuthEvent event,

    /// Current authenticated user, if any.
    AuthUserEntity? user,
  }) = _AuthStateEntity;

  /// Creates the initial auth state snapshot.
  factory AuthStateEntity.initial({
    /// Current authenticated user, if any.
    AuthUserEntity? user,
  }) {
    return AuthStateEntity(event: AuthEvent.initial, user: user);
  }

  /// Private constructor for Freezed extensions/getters.
  const AuthStateEntity._();

  /// True when a user session is active.
  bool get isAuthenticated => user != null;
}
