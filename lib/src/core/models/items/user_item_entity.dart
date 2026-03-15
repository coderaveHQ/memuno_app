import 'package:flutter/foundation.dart';

/// Canonical user payload entity matching `public.user_item`.
@immutable
final class UserItemEntity {
  const UserItemEntity({
    required this.id,
    required this.name,
    required this.friendshipCode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String friendshipCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserItemEntity copyWith({
    String? id,
    String? name,
    String? friendshipCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      friendshipCode: friendshipCode ?? this.friendshipCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
