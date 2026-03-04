// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_dto.dart';

part 'friendship_request_list_page_dto.freezed.dart';
part 'friendship_request_list_page_dto.g.dart';

/// DTO matching `public.friendship_request_list_page`.
@freezed
sealed class FriendshipRequestListPageDto with _$FriendshipRequestListPageDto {
  /// Creates a friendship-request-list page DTO.
  const factory FriendshipRequestListPageDto({
    /// Page items.
    required List<FriendshipRequestListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _FriendshipRequestListPageDto;

  /// Creates a friendship-request-list page DTO from JSON.
  factory FriendshipRequestListPageDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipRequestListPageDtoFromJson(json);
}
