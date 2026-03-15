import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for toggling one user-details meme laugh state.
final class ToggleUserDetailsMemeLaughUsecase {
  /// Creates the usecase.
  const ToggleUserDetailsMemeLaughUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Toggles one meme laugh and returns the resulting liked-state.
  Future<bool> call({
    /// Meme id to like or unlike.
    required String memeId,
  }) {
    return _repository.toggleUserDetailsMemeLaugh(memeId: memeId);
  }
}
