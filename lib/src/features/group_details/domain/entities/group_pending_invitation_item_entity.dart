import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_status.dart';

/// One pending invitation row in group-details info.
@immutable
final class GroupPendingInvitationItemEntity {
  const GroupPendingInvitationItemEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.invitee,
    required this.inviter,
  });

  final String id;
  final GroupInvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserItemEntity invitee;
  final UserItemEntity inviter;
}
