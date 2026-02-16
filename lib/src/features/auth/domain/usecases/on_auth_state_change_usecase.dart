import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: observe authentication state changes.
final class OnAuthStateChangeUsecase {
  /// Creates the usecase.
  const OnAuthStateChangeUsecase({
    /// Repository used to observe auth changes.
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// Auth repository used to stream auth state.
  final AuthRepository _authRepository;

  /// Returns a stream of [AuthStateEntity] updates.
  Stream<AuthStateEntity> call() {
    return _authRepository.onAuthStateChange();
  }
}
