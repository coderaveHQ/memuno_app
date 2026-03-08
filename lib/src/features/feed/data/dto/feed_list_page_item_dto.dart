// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_user_dto.dart';

part 'feed_list_page_item_dto.freezed.dart';
part 'feed_list_page_item_dto.g.dart';

/// DTO matching `public.feed_list_page_item`.
@freezed
sealed class FeedListPageItemDto with _$FeedListPageItemDto {
  /// Creates a feed-list item DTO.
  const factory FeedListPageItemDto({
    /// Nested meme payload.
    required FeedListPageItemMemeDto meme,

    /// Nested creator user payload.
    required FeedListPageItemUserDto user,
  }) = _FeedListPageItemDto;

  /// Creates a feed-list item DTO from JSON.
  factory FeedListPageItemDto.fromJson(Map<String, Object?> json) =>
      _$FeedListPageItemDtoFromJson(json);
}
