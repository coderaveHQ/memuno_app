// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_list_page_item_dto.dart';

part 'meme_template_list_page_dto.freezed.dart';
part 'meme_template_list_page_dto.g.dart';

/// DTO matching `public.meme_template_list_page`.
@freezed
sealed class MemeTemplateListPageDto with _$MemeTemplateListPageDto {
  /// Creates a meme-template-list page DTO.
  const factory MemeTemplateListPageDto({
    /// Page items.
    required List<MemeTemplateListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _MemeTemplateListPageDto;

  /// Creates a meme-template-list page DTO from JSON.
  factory MemeTemplateListPageDto.fromJson(Map<String, Object?> json) =>
      _$MemeTemplateListPageDtoFromJson(json);
}
