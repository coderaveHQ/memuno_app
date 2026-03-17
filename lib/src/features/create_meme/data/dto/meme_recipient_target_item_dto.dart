import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_type.dart';

/// DTO matching `public.meme_recipient_target_item`.
@immutable
final class MemeRecipientTargetItemDto {
  const MemeRecipientTargetItemDto({
    required this.type,
    required this.id,
    required this.name,
    required this.friendshipCode,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemeRecipientTargetItemDto.fromJson(Map<String, Object?> json) {
    return MemeRecipientTargetItemDto(
      type: MemeRecipientTargetType.fromDatabaseValue(
        _readRequiredString(json, 'type'),
      ),
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      friendshipCode: _readNullableString(json, 'friendship_code'),
      memberCount: _readNullableInt(json, 'member_count'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
    );
  }

  final MemeRecipientTargetType type;
  final String id;
  final String name;
  final String? friendshipCode;
  final int? memberCount;
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

String? _readNullableString(Map<String, Object?> payload, String key) {
  if (!payload.containsKey(key)) {
    throw FormatException('Expected nullable string field `$key`.');
  }

  final Object? value = payload[key];
  if (value == null) {
    return null;
  }

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected nullable string field `$key`.');
  }

  return value;
}

int? _readNullableInt(Map<String, Object?> payload, String key) {
  if (!payload.containsKey(key)) {
    throw FormatException('Expected nullable integer field `$key`.');
  }

  final Object? value = payload[key];
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw FormatException('Expected nullable integer field `$key`.');
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
