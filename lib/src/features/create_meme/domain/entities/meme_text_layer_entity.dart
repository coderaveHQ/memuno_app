/// Immutable text layer placed on top of a meme template.
final class MemeTextLayerEntity {
  /// Creates a text layer entity.
  const MemeTextLayerEntity({
    required this.id,
    required this.text,
    required this.positionX,
    required this.positionY,
    required this.fontSize,
    required this.rotationRadians,
    required this.textColorValue,
    required this.hasBackground,
    required this.backgroundColorValue,
  });

  /// Stable identifier used by the editor for selection and updates.
  final String id;

  /// User-entered text rendered on the meme image.
  final String text;

  /// Horizontal center position normalized between 0.0 and 1.0.
  final double positionX;

  /// Vertical center position normalized between 0.0 and 1.0.
  final double positionY;

  /// Rendered text size in logical pixels.
  final double fontSize;

  /// Clockwise layer rotation in radians.
  final double rotationRadians;

  /// ARGB color value used for layer text paint.
  final int textColorValue;

  /// Whether opposite-color text outline is currently visible.
  final bool hasBackground;

  /// ARGB color value used for the optional text outline.
  final int backgroundColorValue;

  /// Returns a new layer with updated fields.
  MemeTextLayerEntity copyWith({
    String? text,
    double? positionX,
    double? positionY,
    double? fontSize,
    double? rotationRadians,
    int? textColorValue,
    bool? hasBackground,
    int? backgroundColorValue,
  }) {
    return MemeTextLayerEntity(
      id: id,
      text: text ?? this.text,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      fontSize: fontSize ?? this.fontSize,
      rotationRadians: rotationRadians ?? this.rotationRadians,
      textColorValue: textColorValue ?? this.textColorValue,
      hasBackground: hasBackground ?? this.hasBackground,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
    );
  }
}
