import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';

/// Repository contract for gallery-based meme-template image selection.
abstract class MemeTemplateGalleryRepository {
  /// Picks one image from gallery and crops it to produce PNG bytes.
  Future<PickedMemeTemplateImageEntity?> pickAndCropGalleryImage();
}
