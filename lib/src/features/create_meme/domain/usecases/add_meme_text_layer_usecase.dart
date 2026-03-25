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
    required String initialText,

    /// Horizontal center position normalized between 0.0 and 1.0.
    required double positionX,

    /// Vertical center position normalized between 0.0 and 1.0.
    required double positionY,
  }) {
    final Failure? textValidation = _validator.validateTextLayerText(
      initialText,
    );
    if (textValidation != null) {
      throw textValidation;
    }

    final Failure? positionXValidation = _validator.validateNormalizedPosition(
      positionX,
    );
    if (positionXValidation != null) {
      throw positionXValidation;
    }

    final Failure? positionYValidation = _validator.validateNormalizedPosition(
      positionY,
    );
    if (positionYValidation != null) {
      throw positionYValidation;
    }

    return _repository.addTextLayer(
      state: state,
      initialText: initialText,
      positionX: positionX,
      positionY: positionY,
    );
  }
}
