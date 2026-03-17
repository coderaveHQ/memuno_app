import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';

/// DTO matching `public.group_member_item`.
@immutable
final class GroupMemberItemDto {
  const GroupMemberItemDto({
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory GroupMemberItemDto.fromJson(Map<String, Object?> json) {
    final Object? rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException('Expected `user` to be an object payload.');
    }

    return GroupMemberItemDto(
      type: GroupUserType.fromDatabaseValue(_readRequiredString(json, 'type')),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
      user: UserItemDto.fromJson(Map<String, Object?>.from(rawUser)),
    );
  }

  final GroupUserType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserItemDto user;
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
