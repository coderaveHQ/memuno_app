import 'package:memuno_app/src/features/meme_templates/data/datasources/device_meme_template_gallery_datasource_impl.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_template_gallery_datasource.dart';
import 'package:memuno_app/src/infrastructure/image_cropper/image_cropper_service.dart';
import 'package:memuno_app/src/infrastructure/image_picker/image_picker_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_template_gallery_datasource_provider.g.dart';

/// Provides the meme-template gallery datasource implementation.
@Riverpod(keepAlive: true)
MemeTemplateGalleryDatasource memeTemplateGalleryDatasource(Ref ref) {
  final ImagePickerService imagePickerService = ref.watch(
    imagePickerServiceProvider,
  );
  final ImageCropperService imageCropperService = ref.watch(
    imageCropperServiceProvider,
  );

  return DeviceMemeTemplateGalleryDatasourceImpl(
    imagePickerService: imagePickerService,
    imageCropperService: imageCropperService,
  );
}
