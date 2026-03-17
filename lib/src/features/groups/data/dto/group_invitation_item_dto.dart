import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_item_dto.dart';

/// DTO matching `public.group_invitation_item`.
@immutable
final class GroupInvitationItemDto {
  const GroupInvitationItemDto({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.group,
    required this.inviter,
  });

  factory GroupInvitationItemDto.fromJson(Map<String, Object?> json) {
    final Object? rawGroup = json['group'];
    if (rawGroup is! Map) {
      throw const FormatException('Expected `group` to be an object payload.');
    }

    final Object? rawInviter = json['inviter'];
    if (rawInviter is! Map) {
      throw const FormatException(
        'Expected `inviter` to be an object payload.',
      );
    }

    return GroupInvitationItemDto(
      id: _readRequiredString(json, 'id'),
      status: _readRequiredString(json, 'status'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
      group: GroupItemDto.fromJson(Map<String, Object?>.from(rawGroup)),
      inviter: UserItemDto.fromJson(Map<String, Object?>.from(rawInviter)),
    );
  }

  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GroupItemDto group;
  final UserItemDto inviter;
}

String _readRequiredString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string field `$key`.');
  }
  return value;
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
