import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for resolving source pixel size of the selected meme background.
final class ResolveMemeBackgroundSizeUsecase {
  /// Creates the usecase.
  const ResolveMemeBackgroundSizeUsecase({
    required MemeEditorRenderRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for render-size resolution.
  final MemeEditorRenderRepository _repository;

  /// Validator used for state and size checks.
  final MemeEditorValidator _validator;

  /// Resolves source pixel dimensions from [state].
  Future<MemeImageSizeEntity> call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  }) async {
    final Failure? backgroundValidation = _validator.validateTemplateSelected(
      state,
    );
    if (backgroundValidation != null) {
      throw backgroundValidation;
    }

    final MemeImageSizeEntity size = await _repository.resolveBackgroundSize(
      state: state,
    );

    final Failure? sizeValidation = _validator.validateImageSize(size);
    if (sizeValidation != null) {
      throw sizeValidation;
    }

    return size;
  }
}
