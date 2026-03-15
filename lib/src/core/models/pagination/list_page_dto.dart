import 'package:flutter/foundation.dart';

/// Canonical list page DTO matching `public.list_page`.
@immutable
final class ListPageDto<TItem> {
  const ListPageDto({
    required this.items,
    required this.nextCursorCreatedAt,
    required this.nextCursorId,
  });

  factory ListPageDto.fromJson(
    Map<String, Object?> json, {
    required TItem Function(Map<String, Object?> json) itemFromJson,
  }) {
    final Object? rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Expected `items` to be a JSON array.');
    }

    final List<TItem> items = rawItems.map((Object? rawItem) {
      if (rawItem is! Map) {
        throw const FormatException('Expected list item to be an object.');
      }
      return itemFromJson(Map<String, Object?>.from(rawItem));
    }).toList(growable: false);

    return ListPageDto<TItem>(
      items: items,
      nextCursorCreatedAt: _readOptionalDateTime(json, 'next_cursor_created_at'),
      nextCursorId: _readOptionalString(json, 'next_cursor_id'),
    );
  }

  final List<TItem> items;
  final DateTime? nextCursorCreatedAt;
  final String? nextCursorId;
}

String? _readOptionalString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected string or null field `$key`.');
  }
  return value;
}

DateTime? _readOptionalDateTime(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected timestamp string or null field `$key`.');
  }

  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected ISO-8601 timestamp field `$key`.');
  }
  return parsed;
}
