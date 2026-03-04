// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_request_list_page_item_user_dto.freezed.dart';
part 'friendship_request_list_page_item_user_dto.g.dart';

/// DTO matching `public.friendship_request_list_page_item_user`.
@freezed
sealed class FriendshipRequestListPageItemUserDto
    with _$FriendshipRequestListPageItemUserDto {
  /// Creates a friendship-request-list item user DTO.
  const factory FriendshipRequestListPageItemUserDto({
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
  }) = _FriendshipRequestListPageItemUserDto;

  /// Creates a friendship-request-list item user DTO from JSON.
  factory FriendshipRequestListPageItemUserDto.fromJson(
    Map<String, Object?> json,
  ) => _$FriendshipRequestListPageItemUserDtoFromJson(json);
}
