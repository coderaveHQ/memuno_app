// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_dto.dart';

part 'friendship_list_page_dto.freezed.dart';
part 'friendship_list_page_dto.g.dart';

/// DTO matching `public.friendship_list_page`.
@freezed
sealed class FriendshipListPageDto with _$FriendshipListPageDto {
  /// Creates a friendship-list page DTO.
  const factory FriendshipListPageDto({
    /// Page items.
    required List<FriendshipListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _FriendshipListPageDto;

  /// Creates a friendship-list page DTO from JSON.
  factory FriendshipListPageDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipListPageDtoFromJson(json);
}
