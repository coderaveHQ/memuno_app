/// Immutable size descriptor for one meme image in physical pixels.
final class MemeImageSizeEntity {
  /// Creates a meme-image size value.
  const MemeImageSizeEntity({required this.width, required this.height});

  /// Image width in pixels.
  final int width;

  /// Image height in pixels.
  final int height;
}
