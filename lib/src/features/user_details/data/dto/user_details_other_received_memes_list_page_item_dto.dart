// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_user_dto.dart';

part 'user_details_other_received_memes_list_page_item_dto.freezed.dart';
part 'user_details_other_received_memes_list_page_item_dto.g.dart';

/// DTO matching `public.user_details_other_received_memes_list_page_item`.
@freezed
sealed class UserDetailsOtherReceivedMemesListPageItemDto
    with _$UserDetailsOtherReceivedMemesListPageItemDto {
  /// Creates one other-received memes-list item DTO.
  const factory UserDetailsOtherReceivedMemesListPageItemDto({
    /// Nested meme payload.
    required UserDetailsOtherReceivedMemesListPageItemMemeDto meme,

    /// Nested creator user payload.
    required UserDetailsOtherReceivedMemesListPageItemUserDto user,
  }) = _UserDetailsOtherReceivedMemesListPageItemDto;

  /// Creates one other-received memes-list item DTO from JSON.
  factory UserDetailsOtherReceivedMemesListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOtherReceivedMemesListPageItemDtoFromJson(json);
}
