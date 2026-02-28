import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_template_gallery_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';
import 'package:memuno_app/src/infrastructure/image_cropper/image_cropper_service.dart';
import 'package:memuno_app/src/infrastructure/image_picker/image_picker_service.dart';

/// Device-backed implementation of [MemeTemplateGalleryDatasource].
final class DeviceMemeTemplateGalleryDatasourceImpl
    implements MemeTemplateGalleryDatasource {
  /// Creates the datasource.
  const DeviceMemeTemplateGalleryDatasourceImpl({
    required ImagePickerService imagePickerService,
    required ImageCropperService imageCropperService,
  }) : _imagePickerService = imagePickerService,
       _imageCropperService = imageCropperService;

  /// Service used for platform gallery selection.
  final ImagePickerService _imagePickerService;

  /// Service used for platform cropper UI.
  final ImageCropperService _imageCropperService;

  @override
  Future<PickedMemeTemplateImageEntity?> pickAndCropGalleryImage() async {
    try {
      final XFile? pickedFile = await _imagePickerService
          .pickImageFromGallery();
      if (pickedFile == null) {
        return null;
      }

      final CroppedFile? croppedFile = await _imageCropperService.cropImage(
        sourcePath: pickedFile.path,
      );
      if (croppedFile == null) {
        return null;
      }

      final Uint8List croppedBytes = await croppedFile.readAsBytes();
      final img.Image? decodedImage = img.decodeImage(croppedBytes);
      if (decodedImage == null) {
        throw const Failure.validation(
          code: 'invalid_format',
          field: 'gallery_image',
        );
      }

      final Uint8List pngBytes = Uint8List.fromList(
        img.encodePng(decodedImage),
      );
      final double aspectRatio = decodedImage.height == 0
          ? 1.0
          : decodedImage.width / decodedImage.height;

      return PickedMemeTemplateImageEntity(
        pngBytes: pngBytes,
        aspectRatio: aspectRatio,
      );
    } on PlatformException catch (error) {
      if (_isPermissionError(error)) {
        throw const Failure.validation(
          code: 'gallery_permission_denied',
          field: 'gallery_permission',
        );
      }
      rethrow;
    }
  }

  /// Returns whether [error] represents a gallery-permission denial.
  bool _isPermissionError(PlatformException error) {
    final String code = error.code.toLowerCase();
    final String message = (error.message ?? '').toLowerCase();

    return code.contains('permission') ||
        code.contains('access_denied') ||
        code.contains('photo_access_denied') ||
        message.contains('permission') ||
        message.contains('denied');
  }
}
