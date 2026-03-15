import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';

/// Canonical meme payload entity matching `public.meme_item`.
@immutable
final class MemeItemEntity {
  const MemeItemEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.signedImageUrl,
    required this.aspectRatio,
    required this.laughCount,
    required this.isLaughed,
    required this.user,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String signedImageUrl;
  final double aspectRatio;
  final int laughCount;
  final bool isLaughed;
  final UserItemEntity user;

  MemeItemEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? signedImageUrl,
    double? aspectRatio,
    int? laughCount,
    bool? isLaughed,
    UserItemEntity? user,
  }) {
    return MemeItemEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      signedImageUrl: signedImageUrl ?? this.signedImageUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      laughCount: laughCount ?? this.laughCount,
      isLaughed: isLaughed ?? this.isLaughed,
      user: user ?? this.user,
    );
  }
}
