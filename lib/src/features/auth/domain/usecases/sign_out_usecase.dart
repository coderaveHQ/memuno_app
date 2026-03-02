import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: sign out.
final class SignOutUsecase {
  /// Creates the usecase.
  const SignOutUsecase({
    /// Repository used to perform auth operations.
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// Auth repository used for sign-out calls.
  final AuthRepository _authRepository;

  /// Signs the current user out.
  Future<void> call() async {
    await _authRepository.signOut();
  }
}
