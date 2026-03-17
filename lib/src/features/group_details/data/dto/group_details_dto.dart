import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// DTO matching `public.group_details`.
@immutable
final class GroupDetailsDto {
  const GroupDetailsDto({
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

  factory GroupDetailsDto.fromJson(Map<String, Object?> json) {
    return GroupDetailsDto(
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      memberCount: _readRequiredInt(json, 'member_count'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
      myUserType: _readNullableGroupUserType(json, 'my_user_type'),
      isMember: _readRequiredBool(json, 'is_member'),
      hasPendingInvitation: _readRequiredBool(json, 'has_pending_invitation'),
      canManageMembers: _readRequiredBool(json, 'can_manage_members'),
      canAddMembers: _readRequiredBool(json, 'can_add_members'),
      canDeleteGroup: _readRequiredBool(json, 'can_delete_group'),
    );
  }

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

String _readRequiredString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string field `$key`.');
  }
  return value;
}

int _readRequiredInt(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected integer field `$key`.');
}

DateTime _readRequiredDateTime(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty timestamp field `$key`.');
  }

  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected ISO-8601 timestamp field `$key`.');
  }

  return parsed;
}

bool _readRequiredBool(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! bool) {
    throw FormatException('Expected boolean field `$key`.');
  }
  return value;
}

GroupUserType? _readNullableGroupUserType(
  Map<String, Object?> payload,
  String key,
) {
  if (!payload.containsKey(key)) {
    throw FormatException('Expected nullable group-user-type field `$key`.');
  }

  final Object? value = payload[key];
  if (value == null) {
    return null;
  }

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected nullable group-user-type field `$key`.');
  }

  return GroupUserType.fromDatabaseValue(value);
}
