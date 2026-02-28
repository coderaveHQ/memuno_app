import 'dart:typed_data';

/// Domain entity containing one picked and cropped gallery image.
final class PickedMemeTemplateImageEntity {
  /// Creates a picked meme-template image entity.
  const PickedMemeTemplateImageEntity({
    required this.pngBytes,
    required this.aspectRatio,
  });

  /// PNG bytes of the picked image.
  final Uint8List pngBytes;

  /// Positive aspect ratio (`width / height`) of [pngBytes].
  final double aspectRatio;
}
