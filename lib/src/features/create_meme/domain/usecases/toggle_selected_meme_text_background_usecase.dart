import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';

/// Usecase for toggling background visibility on the selected text layer.
final class ToggleSelectedMemeTextBackgroundUsecase {
  /// Creates the usecase.
  const ToggleSelectedMemeTextBackgroundUsecase({
    required MemeEditorRepository repository,
  }) : _repository = repository;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Toggles selected-layer background visibility.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  }) {
    return _repository.toggleSelectedTextBackground(state: state);
  }
}
