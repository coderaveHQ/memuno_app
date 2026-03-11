import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';

/// Usecase for toggling laugh state from a widget action.
final class ToggleMemeWidgetLaughUsecase {
  /// Creates the usecase.
  const ToggleMemeWidgetLaughUsecase({
    required MemeWidgetRemoteRepository repository,
  }) : _repository = repository;

  final MemeWidgetRemoteRepository _repository;

  /// Toggles laugh state for [memeId] and returns the resulting state.
  Future<bool> call({required String memeId}) {
    return _repository.toggleMemeLaugh(memeId: memeId);
  }
}
