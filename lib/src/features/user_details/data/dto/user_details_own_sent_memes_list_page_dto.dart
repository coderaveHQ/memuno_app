// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_dto.dart';

part 'user_details_own_sent_memes_list_page_dto.freezed.dart';
part 'user_details_own_sent_memes_list_page_dto.g.dart';

/// DTO matching `public.user_details_own_sent_memes_list_page`.
@freezed
sealed class UserDetailsOwnSentMemesListPageDto
    with _$UserDetailsOwnSentMemesListPageDto {
  /// Creates one own-sent memes-list page DTO.
  const factory UserDetailsOwnSentMemesListPageDto({
    /// Page items.
    required List<UserDetailsOwnSentMemesListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _UserDetailsOwnSentMemesListPageDto;

  /// Creates one own-sent memes-list page DTO from JSON.
  factory UserDetailsOwnSentMemesListPageDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnSentMemesListPageDtoFromJson(json);
}
