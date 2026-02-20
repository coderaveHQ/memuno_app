import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for storing finalized image bytes in editor state.
final class SetFinalizedMemeBytesUsecase {
  /// Creates the usecase.
  const SetFinalizedMemeBytesUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for finalization checks.
  final MemeEditorValidator _validator;

  /// Stores finalized [bytes] after validating state and payload.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Finalized meme image bytes.
    required Uint8List bytes,
  }) {
    final Failure? templateValidation = _validator.validateTemplateSelected(
      state,
    );
    if (templateValidation != null) {
      throw templateValidation;
    }

    final Failure? bytesValidation = _validator.validateFinalizedBytes(bytes);
    if (bytesValidation != null) {
      throw bytesValidation;
    }

    return _repository.setFinalizedImageBytes(state: state, bytes: bytes);
  }
}
