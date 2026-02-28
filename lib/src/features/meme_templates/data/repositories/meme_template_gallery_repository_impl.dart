import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_template_gallery_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_template_gallery_repository.dart';

/// Repository implementation for gallery-based meme-template image selection.
final class MemeTemplateGalleryRepositoryImpl
    implements MemeTemplateGalleryRepository {
  /// Creates the repository.
  const MemeTemplateGalleryRepositoryImpl({
    required MemeTemplateGalleryDatasource memeTemplateGalleryDatasource,
    required FailureMapper failureMapper,
  }) : _memeTemplateGalleryDatasource = memeTemplateGalleryDatasource,
       _failureMapper = failureMapper;

  /// Datasource used for device picker/cropper execution.
  final MemeTemplateGalleryDatasource _memeTemplateGalleryDatasource;

  /// Mapper used to normalize thrown errors into failures.
  final FailureMapper _failureMapper;

  @override
  Future<PickedMemeTemplateImageEntity?> pickAndCropGalleryImage() async {
    try {
      return await _memeTemplateGalleryDatasource.pickAndCropGalleryImage();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
