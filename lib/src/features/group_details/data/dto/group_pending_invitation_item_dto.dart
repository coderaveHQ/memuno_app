import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_status.dart';

/// DTO matching `public.group_pending_invitation_item`.
@immutable
final class GroupPendingInvitationItemDto {
  const GroupPendingInvitationItemDto({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.invitee,
    required this.inviter,
  });

  factory GroupPendingInvitationItemDto.fromJson(Map<String, Object?> json) {
    final Object? rawInvitee = json['invitee'];
    if (rawInvitee is! Map) {
      throw const FormatException(
        'Expected `invitee` to be an object payload.',
      );
    }

    final Object? rawInviter = json['inviter'];
    if (rawInviter is! Map) {
      throw const FormatException(
        'Expected `inviter` to be an object payload.',
      );
    }

    return GroupPendingInvitationItemDto(
      id: _readRequiredString(json, 'id'),
      status: GroupInvitationStatus.fromDatabaseValue(
        _readRequiredString(json, 'status'),
      ),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
      invitee: UserItemDto.fromJson(Map<String, Object?>.from(rawInvitee)),
      inviter: UserItemDto.fromJson(Map<String, Object?>.from(rawInviter)),
    );
  }

  final String id;
  final GroupInvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserItemDto invitee;
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
