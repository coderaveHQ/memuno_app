// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_list_page_item_user_dto.freezed.dart';
part 'feed_list_page_item_user_dto.g.dart';

/// DTO matching `public.feed_list_page_item_user`.
@freezed
sealed class FeedListPageItemUserDto with _$FeedListPageItemUserDto {
  /// Creates a feed-list item user DTO.
  const factory FeedListPageItemUserDto({
    /// User id.
    required String id,

    /// User display name.
    required String name,

    /// User friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,

    /// User creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// User update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FeedListPageItemUserDto;

  /// Creates a feed-list item user DTO from JSON.
  factory FeedListPageItemUserDto.fromJson(Map<String, Object?> json) =>
      _$FeedListPageItemUserDtoFromJson(json);
}
