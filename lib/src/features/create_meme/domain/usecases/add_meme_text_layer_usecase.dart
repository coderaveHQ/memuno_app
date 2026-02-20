import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for adding one text layer to the meme editor.
final class AddMemeTextLayerUsecase {
  /// Creates the usecase.
  const AddMemeTextLayerUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for text-layer input checks.
  final MemeEditorValidator _validator;

  /// Adds one layer with [initialText] and selects it.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Initial text rendered by the new layer.
    String initialText = 'Text',
  }) {
    final Failure? validation = _validator.validateTextLayerText(initialText);
    if (validation != null) {
      throw validation;
    }

    return _repository.addTextLayer(state: state, initialText: initialText);
  }
}
