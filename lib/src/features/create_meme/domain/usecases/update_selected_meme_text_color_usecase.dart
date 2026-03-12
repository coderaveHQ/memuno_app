import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for updating text color of the selected meme text layer.
final class UpdateSelectedMemeTextColorUsecase {
  /// Creates the usecase.
  const UpdateSelectedMemeTextColorUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for color input checks.
  final MemeEditorValidator _validator;

  /// Updates selected-layer text color to [colorValue].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Next selected-layer ARGB text color value.
    required int colorValue,
  }) {
    final Failure? colorValidation = _validator.validateColorValue(colorValue);
    if (colorValidation != null) {
      throw colorValidation;
    }

    return _repository.updateSelectedTextColor(
      state: state,
      colorValue: colorValue,
    );
  }
}
