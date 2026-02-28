import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for selecting one custom gallery image as meme background.
final class SetCustomMemeTemplateImageUsecase {
  /// Creates the usecase.
  const SetCustomMemeTemplateImageUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for custom-image checks.
  final MemeEditorValidator _validator;

  /// Applies [imageBytes] and [aspectRatio] as selected custom meme background.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// PNG bytes of the selected custom image.
    required Uint8List imageBytes,

    /// Aspect ratio (`width / height`) of [imageBytes].
    required double aspectRatio,
  }) {
    final Failure? imageBytesValidation = _validator.validateSelectedImageBytes(
      imageBytes,
    );
    if (imageBytesValidation != null) {
      throw imageBytesValidation;
    }

    final Failure? aspectRatioValidation = _validator.validateAspectRatio(
      aspectRatio,
    );
    if (aspectRatioValidation != null) {
      throw aspectRatioValidation;
    }

    return _repository.setCustomTemplateImage(
      state: state,
      imageBytes: imageBytes,
      aspectRatio: aspectRatio,
    );
  }
}
