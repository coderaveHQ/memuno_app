import 'package:flutter/foundation.dart';

/// Canonical user payload DTO matching `public.user_item`.
@immutable
final class UserItemDto {
  const UserItemDto({
    required this.id,
    required this.name,
    required this.friendshipCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserItemDto.fromJson(Map<String, Object?> json) {
    return UserItemDto(
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      friendshipCode: _readRequiredString(json, 'friendship_code'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
    );
  }

  final String id;
  final String name;
  final String friendshipCode;
  final DateTime createdAt;
  final DateTime updatedAt;
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
