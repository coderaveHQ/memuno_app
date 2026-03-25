import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for updating text of the currently selected layer.
final class UpdateSelectedMemeTextUsecase {
  /// Creates the usecase.
  const UpdateSelectedMemeTextUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for text-layer input checks.
  final MemeEditorValidator _validator;

  /// Updates selected-layer text to [text].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// New text for the selected layer.
    required String text,
  }) {
    final Failure? textValidation = _validator.validateTextLayerText(text);
    if (textValidation != null) {
      throw textValidation;
    }

    return _repository.updateSelectedText(state: state, text: text);
  }
}
