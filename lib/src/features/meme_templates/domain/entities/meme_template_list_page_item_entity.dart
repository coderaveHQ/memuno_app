import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_template_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.meme_template_list_page_item`.
@freezed
sealed class MemeTemplateListPageItemEntity
    with _$MemeTemplateListPageItemEntity {
  /// Creates a meme-template-list item entity.
  const factory MemeTemplateListPageItemEntity({
    /// Stable template identifier.
    required String id,

    /// Template image path stored in Supabase Storage.
    required String imagePath,

    /// Signed image URL used for private template rendering in the client.
    required String signedImageUrl,

    /// Aspect ratio used to render preview tiles.
    required double aspectRatio,

    /// Template creation timestamp used by pagination ordering.
    required DateTime createdAt,

    /// Template update timestamp.
    required DateTime updatedAt,
  }) = _MemeTemplateListPageItemEntity;

  const MemeTemplateListPageItemEntity._();
}
