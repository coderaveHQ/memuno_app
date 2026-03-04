// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_user_dto.dart';

part 'friendship_request_list_page_item_dto.freezed.dart';
part 'friendship_request_list_page_item_dto.g.dart';

/// DTO matching `public.friendship_request_list_page_item`.
@freezed
sealed class FriendshipRequestListPageItemDto
    with _$FriendshipRequestListPageItemDto {
  /// Creates a friendship-request-list item DTO.
  const factory FriendshipRequestListPageItemDto({
    /// Request identifier.
    required String id,

    /// Raw status value from SQL enum.
    required String status,

    /// Request creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Request update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Raw direction value from SQL enum.
    required String direction,

    /// Nested counterpart user payload.
    required FriendshipRequestListPageItemUserDto user,
  }) = _FriendshipRequestListPageItemDto;

  /// Creates a friendship-request-list item DTO from JSON.
  factory FriendshipRequestListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$FriendshipRequestListPageItemDtoFromJson(json);
}
