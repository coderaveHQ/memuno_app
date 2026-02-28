import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_template_gallery_repository.dart';

/// Usecase for selecting one gallery image and cropping it for meme creation.
final class PickAndCropMemeTemplateImageUsecase {
  /// Creates the usecase.
  const PickAndCropMemeTemplateImageUsecase({
    required MemeTemplateGalleryRepository repository,
  }) : _repository = repository;

  /// Repository used for gallery selection workflow.
  final MemeTemplateGalleryRepository _repository;

  /// Picks and crops one gallery image, returning PNG payload on success.
  Future<PickedMemeTemplateImageEntity?> call() {
    return _repository.pickAndCropGalleryImage();
  }
}
