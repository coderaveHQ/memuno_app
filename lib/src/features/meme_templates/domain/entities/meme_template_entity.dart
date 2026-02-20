import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_template_entity.freezed.dart';

/// Domain entity representing an active meme template.
@freezed
sealed class MemeTemplateEntity with _$MemeTemplateEntity {
  /// Creates a meme-template entity.
  const factory MemeTemplateEntity({
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
  }) = _MemeTemplateEntity;

  const MemeTemplateEntity._();
}
