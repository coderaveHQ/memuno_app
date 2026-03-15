// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_item_dto.dart';

part 'meme_laugh_list_page_dto.freezed.dart';
part 'meme_laugh_list_page_dto.g.dart';

/// DTO matching `public.meme_laugh_list_page`.
@freezed
sealed class MemeLaughListPageDto with _$MemeLaughListPageDto {
  /// Creates one meme-laugh-list page DTO.
  const factory MemeLaughListPageDto({
    /// Page items.
    required List<MemeLaughListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _MemeLaughListPageDto;

  /// Creates one meme-laugh-list page DTO from JSON.
  factory MemeLaughListPageDto.fromJson(Map<String, Object?> json) =>
      _$MemeLaughListPageDtoFromJson(json);
}
