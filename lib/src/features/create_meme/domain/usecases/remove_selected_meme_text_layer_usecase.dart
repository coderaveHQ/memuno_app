import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';

/// Usecase for removing the currently selected text layer.
final class RemoveSelectedMemeTextLayerUsecase {
  /// Creates the usecase.
  const RemoveSelectedMemeTextLayerUsecase({
    required MemeEditorRepository repository,
  }) : _repository = repository;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Removes the selected text layer when present.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  }) {
    return _repository.removeSelectedTextLayer(state: state);
  }
}
