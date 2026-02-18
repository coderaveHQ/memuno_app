// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_user_dto.freezed.dart';
part 'friend_user_dto.g.dart';

/// DTO representing minimal user fields embedded in friendship payloads.
@freezed
sealed class FriendUserDto with _$FriendUserDto {
  /// Creates a friend user DTO.
  const factory FriendUserDto({
    /// User identifier.
    required String id,

    /// Display name.
    required String name,

    /// Friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,
  }) = _FriendUserDto;

  /// Creates a friend user DTO from JSON.
  factory FriendUserDto.fromJson(Map<String, Object?> json) =>
      _$FriendUserDtoFromJson(json);
}
