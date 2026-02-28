import 'package:image_cropper/image_cropper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_cropper_provider.g.dart';

/// Provides the app-wide [ImageCropper] instance.
@Riverpod(keepAlive: true)
ImageCropper imageCropper(Ref ref) {
  return ImageCropper();
}
