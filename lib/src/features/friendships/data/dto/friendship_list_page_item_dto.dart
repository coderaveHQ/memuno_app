// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_user_dto.dart';

part 'friendship_list_page_item_dto.freezed.dart';
part 'friendship_list_page_item_dto.g.dart';

/// DTO matching `public.friendship_list_page_item`.
@freezed
sealed class FriendshipListPageItemDto with _$FriendshipListPageItemDto {
  /// Creates a friendship-list item DTO.
  const factory FriendshipListPageItemDto({
    /// Nested friend user payload.
    required FriendshipListPageItemUserDto user,

    /// Friendship creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Friendship update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FriendshipListPageItemDto;

  /// Creates a friendship-list item DTO from JSON.
  factory FriendshipListPageItemDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipListPageItemDtoFromJson(json);
}
