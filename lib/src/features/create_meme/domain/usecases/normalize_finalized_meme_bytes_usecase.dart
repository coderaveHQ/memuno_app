import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for normalizing captured meme bytes to exact target dimensions.
final class NormalizeFinalizedMemeBytesUsecase {
  /// Creates the usecase.
  const NormalizeFinalizedMemeBytesUsecase({
    required MemeEditorRenderRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for byte normalization.
  final MemeEditorRenderRepository _repository;

  /// Validator used for byte and size checks.
  final MemeEditorValidator _validator;

  /// Normalizes captured [bytes] to [targetSize].
  Uint8List call({
    /// Captured meme PNG bytes.
    required Uint8List bytes,

    /// Exact target output size in pixels.
    required MemeImageSizeEntity targetSize,
  }) {
    final Failure? bytesValidation = _validator.validateFinalizedBytes(bytes);
    if (bytesValidation != null) {
      throw bytesValidation;
    }

    final Failure? sizeValidation = _validator.validateImageSize(targetSize);
    if (sizeValidation != null) {
      throw sizeValidation;
    }

    return _repository.normalizeFinalizedImageBytes(
      bytes: bytes,
      targetSize: targetSize,
    );
  }
}
