import 'dart:convert';
import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for shrinking selected custom image bytes to fit upload budget.
final class OptimizeCustomTemplateImageForUploadUsecase {
  /// Creates the usecase.
  const OptimizeCustomTemplateImageForUploadUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for upload-size checks.
  final MemeEditorValidator _validator;

  /// Optimizes selected custom image bytes while preserving text payload budget.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  }) {
    final Uint8List? imageBytes = state.customTemplateImageBytes;
    if (imageBytes == null || imageBytes.isEmpty) {
      return state;
    }

    final int textBytes = _measureTextBytes(state.textLayers);
    final int maxImageBytes =
        MemeEditorValidator.maxCombinedMemePayloadBytes - textBytes;
    if (maxImageBytes <= 0) {
      throw const Failure.validation(
        code: 'meme_payload_too_large',
        field: 'meme_payload',
        params: <String, Object?>{
          'max_bytes': MemeEditorValidator.maxCombinedMemePayloadBytes,
        },
      );
    }

    final MemeEditorStateEntity nextState = _repository
        .optimizeCustomTemplateImageForUpload(
          state: state,
          maxImageBytes: maxImageBytes,
        );

    final int optimizedImageBytes =
        nextState.customTemplateImageBytes?.length ?? 0;
    final Failure? payloadValidation = _validator.validateCombinedPayloadBytes(
      imageBytes: optimizedImageBytes,
      textBytes: textBytes,
    );
    if (payloadValidation != null) {
      throw payloadValidation;
    }

    return nextState;
  }

  /// Returns UTF-8 byte count for all text rendered on the meme.
  int _measureTextBytes(List<MemeTextLayerEntity> textLayers) {
    int bytes = 0;
    for (final MemeTextLayerEntity layer in textLayers) {
      bytes += utf8.encode(layer.text).length;
    }
    return bytes;
  }
}
