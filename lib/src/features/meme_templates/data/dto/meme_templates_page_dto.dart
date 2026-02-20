// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_dto.dart';

part 'meme_templates_page_dto.freezed.dart';
part 'meme_templates_page_dto.g.dart';

/// DTO representing one paginated response from `meme_templates_list` RPC.
@freezed
sealed class MemeTemplatesPageDto with _$MemeTemplatesPageDto {
  /// Creates a meme-templates page DTO.
  const factory MemeTemplatesPageDto({
    /// Meme-template items contained in the page.
    required List<MemeTemplateDto> items,

    /// Next cursor creation timestamp value for pagination.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor id value for pagination.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _MemeTemplatesPageDto;

  /// Creates a meme-templates page DTO from JSON.
  factory MemeTemplatesPageDto.fromJson(Map<String, Object?> json) =>
      _$MemeTemplatesPageDtoFromJson(json);
}
