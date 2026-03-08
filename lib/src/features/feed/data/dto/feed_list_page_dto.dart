// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_dto.dart';

part 'feed_list_page_dto.freezed.dart';
part 'feed_list_page_dto.g.dart';

/// DTO matching `public.feed_list_page`.
@freezed
sealed class FeedListPageDto with _$FeedListPageDto {
  /// Creates a feed-list page DTO.
  const factory FeedListPageDto({
    /// Page items.
    required List<FeedListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _FeedListPageDto;

  /// Creates a feed-list page DTO from JSON.
  factory FeedListPageDto.fromJson(Map<String, Object?> json) =>
      _$FeedListPageDtoFromJson(json);
}
