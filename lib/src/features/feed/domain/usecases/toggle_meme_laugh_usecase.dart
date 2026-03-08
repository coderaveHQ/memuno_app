import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';

/// Usecase for toggling the current user's laugh state for one meme.
final class ToggleMemeLaughUsecase {
  /// Creates the usecase.
  const ToggleMemeLaughUsecase({required FeedRepository repository})
    : _repository = repository;

  final FeedRepository _repository;

  /// Toggles one meme laugh and returns the resulting liked-state.
  Future<bool> call({
    /// Meme id to like/unlike.
    required String memeId,
  }) {
    return _repository.toggleMemeLaugh(memeId: memeId);
  }
}
