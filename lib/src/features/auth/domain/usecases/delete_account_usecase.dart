import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';

/// Usecase: delete the currently signed-in account.
final class DeleteAccountUsecase {
  /// Creates the usecase.
  const DeleteAccountUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  /// Deletes the account.
  Future<void> call() {
    return _authRepository.deleteAccount();
  }
}
