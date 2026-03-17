import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// One group member row in group-details info.
@immutable
final class GroupMemberItemEntity {
  const GroupMemberItemEntity({
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  final GroupUserType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserItemEntity user;

  GroupMemberItemEntity copyWith({
    GroupUserType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserItemEntity? user,
  }) {
    return GroupMemberItemEntity(
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
