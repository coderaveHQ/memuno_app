import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_type.dart';

/// Polymorphic recipient target row for meme-details recipient operations.
@immutable
final class MemeRecipientTargetItemEntity {
  const MemeRecipientTargetItemEntity({
    required this.type,
    required this.id,
    required this.name,
    required this.friendshipCode,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final MemeRecipientTargetType type;
  final String id;
  final String name;
  final String? friendshipCode;
  final int? memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUser => type == MemeRecipientTargetType.user;

  bool get isGroup => type == MemeRecipientTargetType.group;

  MemeRecipientTargetItemEntity copyWith({
    MemeRecipientTargetType? type,
    String? id,
    String? name,
    String? friendshipCode,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemeRecipientTargetItemEntity(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      friendshipCode: friendshipCode ?? this.friendshipCode,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
