import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';

/// Repository contract for groups memberships and invitations.
abstract interface class GroupsRepository {
  /// Loads one groups-list page.
  Future<ListPageEntity<GroupItemEntity>> listGroups({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Loads one incoming-invitations page.
  Future<ListPageEntity<GroupInvitationItemEntity>> listGroupInvitations({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  });

  /// Creates one group with optional invitee ids.
  Future<GroupItemEntity> createGroup({
    required String name,
    required List<String> inviteeUserIds,
  });

  /// Accepts one pending invitation and returns the joined group.
  Future<GroupItemEntity> acceptGroupInvitation({required String invitationId});

  /// Rejects one pending invitation.
  Future<void> rejectGroupInvitation({required String invitationId});

  /// Cancels one pending invitation.
  Future<void> cancelGroupInvitation({required String invitationId});

  /// Removes current user from one group.
  Future<void> leaveGroup({required String groupId});
}
