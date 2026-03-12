import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for updating transform fields of one meme text layer.
final class UpdateMemeTextLayerTransformUsecase {
  /// Creates the usecase.
  const UpdateMemeTextLayerTransformUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for transform input checks.
  final MemeEditorValidator _validator;

  /// Applies transform values to one text layer identified by [layerId].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Target layer identifier.
    required String layerId,

    /// Next horizontal center position normalized between 0.0 and 1.0.
    required double positionX,

    /// Next vertical center position normalized between 0.0 and 1.0.
    required double positionY,

    /// Next text font size.
    required double fontSize,

    /// Next clockwise layer rotation in radians.
    required double rotationRadians,
  }) {
    final Failure? layerValidation = _validator.validateLayerId(layerId);
    if (layerValidation != null) {
      throw layerValidation;
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

    final Failure? fontSizeValidation = _validator.validateFontSize(fontSize);
    if (fontSizeValidation != null) {
      throw fontSizeValidation;
    }

    final Failure? rotationValidation = _validator.validateRotationRadians(
      rotationRadians,
    );
    if (rotationValidation != null) {
      throw rotationValidation;
    }

    return _repository.updateTextLayerTransform(
      state: state,
      layerId: layerId,
      positionX: positionX,
      positionY: positionY,
      fontSize: fontSize,
      rotationRadians: rotationRadians,
    );
  }
}
