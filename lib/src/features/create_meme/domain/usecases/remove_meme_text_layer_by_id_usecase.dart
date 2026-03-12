import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for removing one meme text layer by identifier.
final class RemoveMemeTextLayerByIdUsecase {
  /// Creates the usecase.
  const RemoveMemeTextLayerByIdUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for layer-id checks.
  final MemeEditorValidator _validator;

  /// Removes the layer identified by [layerId] from [state].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Target layer identifier.
    required String layerId,
  }) {
    final Failure? layerValidation = _validator.validateLayerId(layerId);
    if (layerValidation != null) {
      throw layerValidation;
    }

    return _repository.removeTextLayerById(state: state, layerId: layerId);
  }
}
