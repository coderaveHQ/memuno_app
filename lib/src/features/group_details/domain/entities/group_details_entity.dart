import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// Group-details payload with access capability flags.
@immutable
final class GroupDetailsEntity {
  const GroupDetailsEntity({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
    required this.myUserType,
    required this.isMember,
    required this.hasPendingInvitation,
    required this.canManageMembers,
    required this.canAddMembers,
    required this.canDeleteGroup,
  });

  final String id;
  final String name;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GroupUserType? myUserType;
  final bool isMember;
  final bool hasPendingInvitation;
  final bool canManageMembers;
  final bool canAddMembers;
  final bool canDeleteGroup;
}
