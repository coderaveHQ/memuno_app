// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_user_dto.dart';

part 'user_details_own_all_memes_list_page_item_dto.freezed.dart';
part 'user_details_own_all_memes_list_page_item_dto.g.dart';

/// DTO matching `public.user_details_own_all_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnAllMemesListPageItemDto
    with _$UserDetailsOwnAllMemesListPageItemDto {
  /// Creates one own-all memes-list item DTO.
  const factory UserDetailsOwnAllMemesListPageItemDto({
    /// Nested meme payload.
    required UserDetailsOwnAllMemesListPageItemMemeDto meme,

    /// Nested creator user payload.
    required UserDetailsOwnAllMemesListPageItemUserDto user,
  }) = _UserDetailsOwnAllMemesListPageItemDto;

  /// Creates one own-all memes-list item DTO from JSON.
  factory UserDetailsOwnAllMemesListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnAllMemesListPageItemDtoFromJson(json);
}
