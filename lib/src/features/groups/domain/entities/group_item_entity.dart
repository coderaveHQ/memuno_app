import 'package:flutter/foundation.dart';

/// Domain entity matching `public.group_item`.
@immutable
final class GroupItemEntity {
  const GroupItemEntity({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupItemEntity copyWith({
    String? id,
    String? name,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
