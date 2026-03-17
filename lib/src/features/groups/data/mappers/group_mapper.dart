import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_item_dto.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';

/// Maps groups DTOs into domain entities.
final class GroupMapper {
  const GroupMapper();

  GroupItemEntity toDomain(GroupItemDto dto) {
    return GroupItemEntity(
      id: dto.id,
      name: dto.name,
      memberCount: dto.memberCount,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  ListPageEntity<GroupItemEntity> pageToDomain(ListPageDto<GroupItemDto> dto) {
    return ListPageEntity<GroupItemEntity>(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }
}
