/// Immutable text layer placed on top of a meme template.
final class MemeTextLayerEntity {
  /// Creates a text layer entity.
  const MemeTextLayerEntity({
    required this.id,
    required this.text,
    required this.positionX,
    required this.positionY,
    required this.fontSize,
  });

  /// Stable identifier used by the editor for selection and updates.
  final String id;

  /// User-entered text rendered on the meme image.
  final String text;

  /// Horizontal position normalized between 0.0 and 1.0.
  final double positionX;

  /// Vertical position normalized between 0.0 and 1.0.
  final double positionY;

  /// Rendered text size in logical pixels.
  final double fontSize;

  /// Returns a new layer with updated fields.
  MemeTextLayerEntity copyWith({
    String? text,
    double? positionX,
    double? positionY,
    double? fontSize,
  }) {
    return MemeTextLayerEntity(
      id: id,
      text: text ?? this.text,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
