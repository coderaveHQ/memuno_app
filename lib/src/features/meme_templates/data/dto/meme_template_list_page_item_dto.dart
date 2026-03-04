// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_template_list_page_item_dto.freezed.dart';
part 'meme_template_list_page_item_dto.g.dart';

/// DTO matching `public.meme_template_list_page_item`.
@freezed
sealed class MemeTemplateListPageItemDto with _$MemeTemplateListPageItemDto {
  /// Creates a meme-template-list item DTO.
  const factory MemeTemplateListPageItemDto({
    /// Stable template identifier.
    required String id,

    /// Template image path stored in Supabase Storage.
    @JsonKey(name: 'image_path') required String imagePath,

    /// Aspect ratio used for template preview rendering.
    @JsonKey(name: 'aspect_ratio') required double aspectRatio,

    /// Template creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Template update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Signed URL generated client-side for private template access.
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? signedImageUrl,
  }) = _MemeTemplateListPageItemDto;

  /// Creates a meme-template-list item DTO from JSON.
  factory MemeTemplateListPageItemDto.fromJson(Map<String, Object?> json) =>
      _$MemeTemplateListPageItemDtoFromJson(json);
}
