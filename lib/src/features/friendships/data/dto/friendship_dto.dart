// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friend_user_dto.dart';

part 'friendship_dto.freezed.dart';
part 'friendship_dto.g.dart';

/// DTO representing one friendship list item.
@freezed
sealed class FriendshipDto with _$FriendshipDto {
  /// Creates a friendship DTO.
  const factory FriendshipDto({
    /// User payload for the friend.
    required FriendUserDto user,

    /// Friendship creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Friendship update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FriendshipDto;

  /// Creates a friendship DTO from JSON.
  factory FriendshipDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipDtoFromJson(json);
}
