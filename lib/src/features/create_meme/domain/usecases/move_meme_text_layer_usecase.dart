import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for moving one text layer by drag delta.
final class MoveMemeTextLayerUsecase {
  /// Creates the usecase.
  const MoveMemeTextLayerUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for movement input checks.
  final MemeEditorValidator _validator;

  /// Applies drag delta to the layer identified by [layerId].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Target layer identifier.
    required String layerId,

    /// Horizontal drag delta in logical pixels.
    required double deltaX,

    /// Vertical drag delta in logical pixels.
    required double deltaY,

    /// Canvas width in logical pixels.
    required double canvasWidth,

    /// Canvas height in logical pixels.
    required double canvasHeight,
  }) {
    final Failure? layerValidation = _validator.validateLayerId(layerId);
    if (layerValidation != null) {
      throw layerValidation;
    }

    final Failure? sizeValidation = _validator.validateCanvasDimensions(
      width: canvasWidth,
      height: canvasHeight,
    );
    if (sizeValidation != null) {
      throw sizeValidation;
    }

    return _repository.moveTextLayerBy(
      state: state,
      layerId: layerId,
      deltaX: deltaX,
      deltaY: deltaY,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
    );
  }
}
