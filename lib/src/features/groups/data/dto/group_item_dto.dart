import 'package:flutter/foundation.dart';

/// DTO matching `public.group_item`.
@immutable
final class GroupItemDto {
  const GroupItemDto({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupItemDto.fromJson(Map<String, Object?> json) {
    return GroupItemDto(
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      memberCount: _readRequiredInt(json, 'member_count'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
    );
  }

  final String id;
  final String name;
  final int memberCount;
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
