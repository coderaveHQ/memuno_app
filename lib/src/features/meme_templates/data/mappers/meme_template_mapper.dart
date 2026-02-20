import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_dto.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Maps [MemeTemplateDto] values into [MemeTemplateEntity] values.
final class MemeTemplateMapper {
  /// Creates a mapper.
  const MemeTemplateMapper();

  /// Maps a meme-template DTO to the domain entity.
  MemeTemplateEntity toDomain(MemeTemplateDto dto) {
    final String? signedImageUrl = dto.signedImageUrl;
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException(
        'Missing signed image URL for meme template `${dto.id}`.',
      );
    }

    return MemeTemplateEntity(
      id: dto.id,
      imagePath: dto.imagePath,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      createdAt: dto.createdAt,
    );
  }
}
