import 'package:image_picker/image_picker.dart';
import 'package:memuno_app/src/infrastructure/image_picker/image_picker_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_service.g.dart';

/// Service contract for image-picker operations.
abstract interface class ImagePickerService {
  /// Opens the platform gallery and returns the selected image file.
  Future<XFile?> pickImageFromGallery();
}

/// Default [ImagePickerService] implementation backed by [ImagePicker].
final class ImagePickerServiceImpl implements ImagePickerService {
  /// Creates an image-picker service.
  const ImagePickerServiceImpl({required ImagePicker imagePicker})
    : _imagePicker = imagePicker;

  /// Plugin instance used for device gallery access.
  final ImagePicker _imagePicker;

  @override
  Future<XFile?> pickImageFromGallery() {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
  }
}

/// Provides the app-wide [ImagePickerService] implementation.
@Riverpod(keepAlive: true)
ImagePickerService imagePickerService(Ref ref) {
  final ImagePicker imagePicker = ref.watch(imagePickerProvider);
  return ImagePickerServiceImpl(imagePicker: imagePicker);
}
