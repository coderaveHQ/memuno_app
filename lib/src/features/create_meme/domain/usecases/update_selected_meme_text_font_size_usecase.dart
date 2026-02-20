import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for updating font size of the selected text layer.
final class UpdateSelectedMemeTextFontSizeUsecase {
  /// Creates the usecase.
  const UpdateSelectedMemeTextFontSizeUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for font-size checks.
  final MemeEditorValidator _validator;

  /// Updates selected-layer font size to [fontSize].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// New font size for the selected layer.
    required double fontSize,
  }) {
    final Failure? validation = _validator.validateFontSize(fontSize);
    if (validation != null) {
      throw validation;
    }

    return _repository.updateSelectedFontSize(state: state, fontSize: fontSize);
  }
}
