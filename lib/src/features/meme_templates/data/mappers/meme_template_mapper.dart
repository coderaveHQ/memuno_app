import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_list_page_item_dto.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Maps meme-template DTOs into domain entities.
final class MemeTemplateMapper {
  /// Creates a mapper.
  const MemeTemplateMapper();

  /// Maps a meme-template DTO to the domain entity.
  MemeTemplateListPageItemEntity toDomain(MemeTemplateListPageItemDto dto) {
    final String? signedImageUrl = dto.signedImageUrl;
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException(
        'Missing signed image URL for meme template `${dto.id}`.',
      );
    }

    return MemeTemplateListPageItemEntity(
      id: dto.id,
      imagePath: dto.imagePath,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one meme-template-list page DTO to the domain entity.
  MemeTemplateListPageEntity pageToDomain(MemeTemplateListPageDto dto) {
    return MemeTemplateListPageEntity(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }
}
