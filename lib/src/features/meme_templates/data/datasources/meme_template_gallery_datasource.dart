import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';

/// Datasource contract for selecting meme-template images from device gallery.
abstract class MemeTemplateGalleryDatasource {
  /// Picks one gallery image, crops it, and returns PNG payload.
  Future<PickedMemeTemplateImageEntity?> pickAndCropGalleryImage();
}
