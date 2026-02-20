// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_template_dto.freezed.dart';
part 'meme_template_dto.g.dart';

/// DTO representing one meme-template list item.
@freezed
sealed class MemeTemplateDto with _$MemeTemplateDto {
  /// Creates a meme-template DTO.
  const factory MemeTemplateDto({
    /// Stable template identifier.
    required String id,

    /// Template image path stored in Supabase Storage.
    @JsonKey(name: 'image_path') required String imagePath,

    /// Aspect ratio used for template preview rendering.
    @JsonKey(name: 'aspect_ratio') required double aspectRatio,

    /// Template creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Signed URL generated client-side for private template access.
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? signedImageUrl,
  }) = _MemeTemplateDto;

  /// Creates a meme-template DTO from JSON.
  factory MemeTemplateDto.fromJson(Map<String, Object?> json) =>
      _$MemeTemplateDtoFromJson(json);
}
