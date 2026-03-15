// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_item_dto.dart';

part 'user_details_other_sent_memes_list_page_dto.freezed.dart';
part 'user_details_other_sent_memes_list_page_dto.g.dart';

/// DTO matching `public.user_details_other_sent_memes_list_page`.
@freezed
sealed class UserDetailsOtherSentMemesListPageDto
    with _$UserDetailsOtherSentMemesListPageDto {
  /// Creates one other-sent memes-list page DTO.
  const factory UserDetailsOtherSentMemesListPageDto({
    /// Page items.
    required List<UserDetailsOtherSentMemesListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _UserDetailsOtherSentMemesListPageDto;

  /// Creates one other-sent memes-list page DTO from JSON.
  factory UserDetailsOtherSentMemesListPageDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOtherSentMemesListPageDtoFromJson(json);
}
