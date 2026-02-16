import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: return the current authenticated user (if any).
final class CurrentUserUsecase {
  /// Creates the usecase.
  const CurrentUserUsecase({
    /// Repository used to access auth state.
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// Auth repository used for current user lookups.
  final AuthRepository _authRepository;

  /// Returns the current authenticated user or `null`.
  AuthUserEntity? call() {
    return _authRepository.currentUser();
  }
}
