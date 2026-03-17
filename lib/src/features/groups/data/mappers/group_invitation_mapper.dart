import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_invitation_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_mapper.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_status.dart';

/// Maps group invitation DTOs into domain entities.
final class GroupInvitationMapper {
  const GroupInvitationMapper({required GroupMapper groupMapper})
    : _groupMapper = groupMapper;

  final GroupMapper _groupMapper;

  GroupInvitationItemEntity toDomain(GroupInvitationItemDto dto) {
    return GroupInvitationItemEntity(
      id: dto.id,
      status: GroupInvitationStatus.fromDatabaseValue(dto.status),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      group: _groupMapper.toDomain(dto.group),
      inviter: UserItemEntity(
        id: dto.inviter.id,
        name: dto.inviter.name,
        friendshipCode: dto.inviter.friendshipCode,
        createdAt: dto.inviter.createdAt,
        updatedAt: dto.inviter.updatedAt,
      ),
    );
  }

  ListPageEntity<GroupInvitationItemEntity> pageToDomain(
    ListPageDto<GroupInvitationItemDto> dto,
  ) {
    return ListPageEntity<GroupInvitationItemEntity>(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }
}
