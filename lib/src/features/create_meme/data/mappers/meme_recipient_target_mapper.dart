import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/create_meme/data/dto/meme_recipient_target_item_dto.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';

/// Maps recipient-target DTOs into domain entities.
final class MemeRecipientTargetMapper {
  const MemeRecipientTargetMapper();

  MemeRecipientTargetItemEntity toDomain(MemeRecipientTargetItemDto dto) {
    return MemeRecipientTargetItemEntity(
      type: dto.type,
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      memberCount: dto.memberCount,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  ListPageEntity<MemeRecipientTargetItemEntity> pageToDomain(
    ListPageDto<MemeRecipientTargetItemDto> dto,
  ) {
    return ListPageEntity<MemeRecipientTargetItemEntity>(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }
}
