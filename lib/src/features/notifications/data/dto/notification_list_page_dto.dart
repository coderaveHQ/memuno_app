import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_dto.dart';

/// DTO matching `public.notification_list_page`.
final class NotificationListPageDto {
  const NotificationListPageDto({
    required this.items,
    required this.nextCursorCreatedAt,
    required this.nextCursorId,
  });

  /// Parses one notification-list page DTO from JSON.
  factory NotificationListPageDto.fromJson(Map<String, Object?> json) {
    final Object? rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('Expected `items` to be a JSON array.');
    }

    final List<NotificationListPageItemDto> items = rawItems
        .map((Object? rawItem) {
          if (rawItem is! Map) {
            throw const FormatException(
              'Expected each notification item to be an object.',
            );
          }
          return NotificationListPageItemDto.fromJson(
            Map<String, Object?>.from(rawItem),
          );
        })
        .toList(growable: false);

    return NotificationListPageDto(
      items: items,
      nextCursorCreatedAt: _readOptionalDateTime(
        json,
        'next_cursor_created_at',
      ),
      nextCursorId: _readOptionalString(json, 'next_cursor_id'),
    );
  }

  final List<NotificationListPageItemDto> items;
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
