// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_user_dto.dart';

part 'user_details_own_received_memes_list_page_item_dto.freezed.dart';
part 'user_details_own_received_memes_list_page_item_dto.g.dart';

/// DTO matching `public.user_details_own_received_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnReceivedMemesListPageItemDto
    with _$UserDetailsOwnReceivedMemesListPageItemDto {
  /// Creates one own-received memes-list item DTO.
  const factory UserDetailsOwnReceivedMemesListPageItemDto({
    /// Nested meme payload.
    required UserDetailsOwnReceivedMemesListPageItemMemeDto meme,

    /// Nested creator user payload.
    required UserDetailsOwnReceivedMemesListPageItemUserDto user,
  }) = _UserDetailsOwnReceivedMemesListPageItemDto;

  /// Creates one own-received memes-list item DTO from JSON.
  factory UserDetailsOwnReceivedMemesListPageItemDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnReceivedMemesListPageItemDtoFromJson(json);
}
