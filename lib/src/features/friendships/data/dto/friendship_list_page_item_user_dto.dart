// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_list_page_item_user_dto.freezed.dart';
part 'friendship_list_page_item_user_dto.g.dart';

/// DTO matching `public.friendship_list_page_item_user`.
@freezed
sealed class FriendshipListPageItemUserDto
    with _$FriendshipListPageItemUserDto {
  /// Creates a friendship-list item user DTO.
  const factory FriendshipListPageItemUserDto({
    /// User identifier.
    required String id,

    /// Display name.
    required String name,

    /// Friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,

    /// User profile creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// User profile update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FriendshipListPageItemUserDto;

  /// Creates a friendship-list item user DTO from JSON.
  factory FriendshipListPageItemUserDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipListPageItemUserDtoFromJson(json);
}
