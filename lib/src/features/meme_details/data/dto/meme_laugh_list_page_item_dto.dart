// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_item_user_dto.dart';

part 'meme_laugh_list_page_item_dto.freezed.dart';
part 'meme_laugh_list_page_item_dto.g.dart';

/// DTO matching `public.meme_laugh_list_page_item`.
@freezed
sealed class MemeLaughListPageItemDto with _$MemeLaughListPageItemDto {
  /// Creates one meme-laugh-list item DTO.
  const factory MemeLaughListPageItemDto({
    /// Nested laughed user payload.
    required MemeLaughListPageItemUserDto user,

    /// Laugh creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Laugh update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _MemeLaughListPageItemDto;

  /// Creates one meme-laugh-list item DTO from JSON.
  factory MemeLaughListPageItemDto.fromJson(Map<String, Object?> json) =>
      _$MemeLaughListPageItemDtoFromJson(json);
}
