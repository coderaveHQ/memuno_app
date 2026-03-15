// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_user_dto.dart';

part 'user_details_own_sent_memes_list_page_item_dto.freezed.dart';
part 'user_details_own_sent_memes_list_page_item_dto.g.dart';

/// DTO matching `public.user_details_own_sent_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnSentMemesListPageItemDto
    with _$UserDetailsOwnSentMemesListPageItemDto {
  /// Creates one own-sent memes-list item DTO.
  const factory UserDetailsOwnSentMemesListPageItemDto({
    /// Nested meme payload.
    required UserDetailsOwnSentMemesListPageItemMemeDto meme,

    /// Nested creator user payload.
    required UserDetailsOwnSentMemesListPageItemUserDto user,
  }) = _UserDetailsOwnSentMemesListPageItemDto;

  /// Creates one own-sent memes-list item DTO from JSON.
  factory UserDetailsOwnSentMemesListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnSentMemesListPageItemDtoFromJson(json);
}
