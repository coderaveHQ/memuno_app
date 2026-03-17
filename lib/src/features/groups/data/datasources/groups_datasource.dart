import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_invitation_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_item_dto.dart';

/// Low-level datasource for groups RPC calls.
abstract interface class GroupsDatasource {
  /// Loads one page of groups where auth user is a member.
  Future<ListPageDto<GroupItemDto>> listGroups({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Loads one page of incoming pending group invitations.
  Future<ListPageDto<GroupInvitationItemDto>> listGroupInvitations({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  /// Creates one group with pending invitations.
  Future<GroupItemDto> createGroup({
    required String name,
    required List<String> inviteeUserIds,
  });

  /// Accepts one pending invitation.
  Future<GroupItemDto> acceptGroupInvitation({required String invitationId});

  /// Rejects one pending invitation.
  Future<void> rejectGroupInvitation({required String invitationId});

  /// Cancels one pending invitation.
  Future<void> cancelGroupInvitation({required String invitationId});

  /// Removes auth user from one group.
  Future<void> leaveGroup({required String groupId});
}
