import 'package:image_cropper/image_cropper.dart';
import 'package:memuno_app/src/infrastructure/image_cropper/image_cropper_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_cropper_service.g.dart';

/// Service contract for image-cropper operations.
abstract interface class ImageCropperService {
  /// Opens cropper UI for [sourcePath] and returns the cropped image file.
  Future<CroppedFile?> cropImage({required String sourcePath});
}

/// Default [ImageCropperService] implementation backed by [ImageCropper].
final class ImageCropperServiceImpl implements ImageCropperService {
  /// Creates an image-cropper service.
  const ImageCropperServiceImpl({required ImageCropper imageCropper})
    : _imageCropper = imageCropper;

  /// Plugin instance used for platform cropper UI.
  final ImageCropper _imageCropper;

  @override
  Future<CroppedFile?> cropImage({required String sourcePath}) {
    return _imageCropper.cropImage(
      sourcePath: sourcePath,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          cropStyle: CropStyle.rectangle,
          hideBottomControls: false,
        ),
        IOSUiSettings(cropStyle: CropStyle.rectangle),
      ],
    );
  }
}

/// Provides the app-wide [ImageCropperService] implementation.
@Riverpod(keepAlive: true)
ImageCropperService imageCropperService(Ref ref) {
  final ImageCropper imageCropper = ref.watch(imageCropperProvider);
  return ImageCropperServiceImpl(imageCropper: imageCropper);
}
