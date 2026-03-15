// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_user_dto.dart';

part 'user_details_other_all_memes_list_page_item_dto.freezed.dart';
part 'user_details_other_all_memes_list_page_item_dto.g.dart';

/// DTO matching `public.user_details_other_all_memes_list_page_item`.
@freezed
sealed class UserDetailsOtherAllMemesListPageItemDto
    with _$UserDetailsOtherAllMemesListPageItemDto {
  /// Creates one other-all memes-list item DTO.
  const factory UserDetailsOtherAllMemesListPageItemDto({
    /// Nested meme payload.
    required UserDetailsOtherAllMemesListPageItemMemeDto meme,

    /// Nested creator user payload.
    required UserDetailsOtherAllMemesListPageItemUserDto user,
  }) = _UserDetailsOtherAllMemesListPageItemDto;

  /// Creates one other-all memes-list item DTO from JSON.
  factory UserDetailsOtherAllMemesListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOtherAllMemesListPageItemDtoFromJson(json);
}
