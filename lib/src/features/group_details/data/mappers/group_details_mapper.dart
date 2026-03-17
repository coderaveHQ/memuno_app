import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_details_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_member_item_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_pending_invitation_item_dto.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';

/// Maps group-details DTOs into domain entities.
final class GroupDetailsMapper {
  const GroupDetailsMapper();

  GroupDetailsEntity detailsToDomain(GroupDetailsDto dto) {
    return GroupDetailsEntity(
      id: dto.id,
      name: dto.name,
      memberCount: dto.memberCount,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      myUserType: dto.myUserType,
      isMember: dto.isMember,
      hasPendingInvitation: dto.hasPendingInvitation,
      canManageMembers: dto.canManageMembers,
      canAddMembers: dto.canAddMembers,
      canDeleteGroup: dto.canDeleteGroup,
    );
  }

  ListPageEntity<MemeItemEntity> memePageToDomain(
    ListPageDto<MemeItemDto> dto,
  ) {
    return ListPageEntity<MemeItemEntity>(
      items: dto.items.map(_toMemeItemEntity).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  ListPageEntity<GroupMemberItemEntity> membersPageToDomain(
    ListPageDto<GroupMemberItemDto> dto,
  ) {
    return ListPageEntity<GroupMemberItemEntity>(
      items: dto.items.map(_toGroupMemberEntity).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  ListPageEntity<GroupPendingInvitationItemEntity>
  pendingInvitationsPageToDomain(
    ListPageDto<GroupPendingInvitationItemDto> dto,
  ) {
    return ListPageEntity<GroupPendingInvitationItemEntity>(
      items: dto.items
          .map(_toGroupPendingInvitationEntity)
          .toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  ListPageEntity<UserItemEntity> usersPageToDomain(
    ListPageDto<UserItemDto> dto,
  ) {
    return ListPageEntity<UserItemEntity>(
      items: dto.items.map(_toUserItemEntity).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  MemeItemEntity _toMemeItemEntity(MemeItemDto dto) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
    );

    return MemeItemEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
      user: _toUserItemEntity(dto.user),
    );
  }

  GroupMemberItemEntity _toGroupMemberEntity(GroupMemberItemDto dto) {
    return GroupMemberItemEntity(
      type: dto.type,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      user: _toUserItemEntity(dto.user),
    );
  }

  GroupPendingInvitationItemEntity _toGroupPendingInvitationEntity(
    GroupPendingInvitationItemDto dto,
  ) {
    return GroupPendingInvitationItemEntity(
      id: dto.id,
      status: dto.status,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      invitee: _toUserItemEntity(dto.invitee),
      inviter: _toUserItemEntity(dto.inviter),
    );
  }

  UserItemEntity _toUserItemEntity(UserItemDto dto) {
    return UserItemEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  String _requiredSignedImageUrl(
    String? signedImageUrl, {
    required String memeId,
  }) {
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException('Missing signed image URL for meme `$memeId`.');
    }
    return signedImageUrl;
  }
}
