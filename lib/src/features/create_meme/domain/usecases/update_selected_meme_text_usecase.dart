import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';

/// Usecase for updating text of the currently selected layer.
final class UpdateSelectedMemeTextUsecase {
  /// Creates the usecase.
  const UpdateSelectedMemeTextUsecase({
    required MemeEditorRepository repository,
  }) : _repository = repository;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Updates selected-layer text to [text].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// New text for the selected layer.
    required String text,
  }) {
    return _repository.updateSelectedText(state: state, text: text);
  }
}
