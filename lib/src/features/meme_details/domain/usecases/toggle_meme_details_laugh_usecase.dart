import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for toggling the current user's laugh state for one meme.
final class ToggleMemeDetailsLaughUsecase {
  /// Creates the usecase.
  const ToggleMemeDetailsLaughUsecase({
    required MemeDetailsRepository repository,
  }) : _repository = repository;

  final MemeDetailsRepository _repository;

  /// Toggles one meme laugh and returns the resulting liked-state.
  Future<bool> call({
    /// Meme id to like/unlike.
    required String memeId,
  }) {
    return _repository.toggleMemeLaugh(memeId: memeId);
  }
}
