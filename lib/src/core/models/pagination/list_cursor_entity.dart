import 'package:flutter/foundation.dart';

/// Canonical cursor payload for created-at/id based pagination.
@immutable
final class ListCursorEntity {
  const ListCursorEntity({required this.createdAt, required this.id});

  final DateTime createdAt;
  final String id;

  ListCursorEntity copyWith({DateTime? createdAt, String? id}) {
    return ListCursorEntity(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}
