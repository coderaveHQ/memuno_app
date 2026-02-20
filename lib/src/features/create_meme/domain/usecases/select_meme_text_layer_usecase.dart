import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for selecting or clearing a text-layer selection.
final class SelectMemeTextLayerUsecase {
  /// Creates the usecase.
  const SelectMemeTextLayerUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for input checks.
  final MemeEditorValidator _validator;

  /// Selects one text layer by [layerId] or clears selection when null.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Target layer id, or `null` to deselect.
    required String? layerId,
  }) {
    final String? targetLayerId = layerId;
    if (targetLayerId != null) {
      final Failure? validation = _validator.validateLayerId(targetLayerId);
      if (validation != null) {
        throw validation;
      }
    }

    return _repository.selectTextLayer(state: state, layerId: targetLayerId);
  }
}
