import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// Repository contract for group-details pages.
abstract interface class GroupDetailsRepository {
  /// Loads one group-details payload for the provided group id.
  Future<GroupDetailsEntity> getGroupDetails({required String groupId});

  /// Loads one page of all memes sent to the group.
  Future<ListPageEntity<MemeItemEntity>> listGroupDetailsMemesAll({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Loads one page of memes sent by auth user to the group.
  Future<ListPageEntity<MemeItemEntity>> listGroupDetailsMemesSentByMe({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Loads one page of group members.
  Future<ListPageEntity<GroupMemberItemEntity>> listGroupDetailsMembers({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Loads one page of pending group invitations.
  Future<ListPageEntity<GroupPendingInvitationItemEntity>>
  listGroupDetailsPendingInvitations({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Loads one page of current-user friends that can be invited.
  Future<ListPageEntity<UserItemEntity>> listGroupInvitableFriends({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Sends one or more invitations to this group.
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

  /// Removes one member from the group.
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  });

  /// Updates one group name.
  Future<void> updateGroupName({required String groupId, required String name});

  /// Deletes one group.
  Future<void> deleteGroup({required String groupId});
}
