import 'package:flutter/foundation.dart';

/// Canonical list page entity matching `public.list_page`.
@immutable
final class ListPageEntity<TItem> {
  const ListPageEntity({
    required this.items,
    required this.nextCursorCreatedAt,
    required this.nextCursorId,
  });

  final List<TItem> items;
  final DateTime? nextCursorCreatedAt;
  final String? nextCursorId;
}
