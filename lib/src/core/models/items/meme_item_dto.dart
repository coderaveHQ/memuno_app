import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';

/// Canonical meme payload DTO matching `public.meme_item`.
@immutable
final class MemeItemDto {
  const MemeItemDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
    required this.aspectRatio,
    required this.laughCount,
    required this.isLaughed,
    required this.user,
    this.signedImageUrl,
  });

  factory MemeItemDto.fromJson(Map<String, Object?> json) {
    final Object? rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException('Expected `user` to be an object payload.');
    }

    return MemeItemDto(
      id: _readRequiredString(json, 'id'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
      imagePath: _readRequiredString(json, 'image_path'),
      aspectRatio: _readRequiredDouble(json, 'aspect_ratio'),
      laughCount: _readRequiredInt(json, 'laugh_count'),
      isLaughed: _readRequiredBool(json, 'is_laughed'),
      user: UserItemDto.fromJson(Map<String, Object?>.from(rawUser)),
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imagePath;
  final double aspectRatio;
  final int laughCount;
  final bool isLaughed;
  final UserItemDto user;
  final String? signedImageUrl;

  MemeItemDto copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
    double? aspectRatio,
    int? laughCount,
    bool? isLaughed,
    UserItemDto? user,
    String? signedImageUrl,
  }) {
    return MemeItemDto(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      laughCount: laughCount ?? this.laughCount,
      isLaughed: isLaughed ?? this.isLaughed,
      user: user ?? this.user,
      signedImageUrl: signedImageUrl ?? this.signedImageUrl,
    );
  }
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

int _readRequiredInt(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected numeric field `$key`.');
}

double _readRequiredDouble(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! num) {
    throw FormatException('Expected numeric field `$key`.');
  }
  return value.toDouble();
}

bool _readRequiredBool(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! bool) {
    throw FormatException('Expected boolean field `$key`.');
  }
  return value;
}
