import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_status.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';

/// Domain entity matching `public.group_invitation_item`.
@immutable
final class GroupInvitationItemEntity {
  const GroupInvitationItemEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.group,
    required this.inviter,
  });

  final String id;
  final GroupInvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GroupItemEntity group;
  final UserItemEntity inviter;

  GroupInvitationItemEntity copyWith({
    String? id,
    GroupInvitationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    GroupItemEntity? group,
    UserItemEntity? inviter,
  }) {
    return GroupInvitationItemEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      group: group ?? this.group,
      inviter: inviter ?? this.inviter,
    );
  }
}
