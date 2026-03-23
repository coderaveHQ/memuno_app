import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_details_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_member_item_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_pending_invitation_item_dto.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// Low-level datasource for group-details RPC calls.
abstract interface class GroupDetailsDatasource {
  /// Loads group-details payload by group id.
  Future<GroupDetailsDto> getGroupDetails({required String groupId});

  /// Loads one page of all memes sent to the group.
  Future<ListPageDto<MemeItemDto>> listGroupDetailsMemesAll({
    required String groupId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Loads one page of memes sent by auth user to the group.
  Future<ListPageDto<MemeItemDto>> listGroupDetailsMemesSentByMe({
    required String groupId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Loads one page of members.
  Future<ListPageDto<GroupMemberItemDto>> listGroupDetailsMembers({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Loads one page of pending invitations.
  Future<ListPageDto<GroupPendingInvitationItemDto>>
  listGroupDetailsPendingInvitations({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Loads one page of current-user friends that can be invited to this group.
  Future<ListPageDto<UserItemDto>> listGroupInvitableFriends({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Sends one or more invitations for this group.
  Future<void> inviteGroupMembers({
    required String groupId,
    required List<String> inviteeUserIds,
  });

  /// Updates one member role in this group.
  Future<void> updateGroupMemberRole({
    required String groupId,
    required String userId,
    required GroupUserType type,
  });

  /// Removes one member from one group.
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  });

  /// Updates one group name.
  Future<void> updateGroupName({required String groupId, required String name});

  /// Deletes one group.
  Future<void> deleteGroup({required String groupId});
}
