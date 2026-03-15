// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_other_received_memes_list_page_item_user_dto.freezed.dart';
part 'user_details_other_received_memes_list_page_item_user_dto.g.dart';

/// DTO matching `public.user_details_other_received_memes_list_page_item_user`.
@freezed
sealed class UserDetailsOtherReceivedMemesListPageItemUserDto
    with _$UserDetailsOtherReceivedMemesListPageItemUserDto {
  /// Creates one other-received memes-list item user DTO.
  const factory UserDetailsOtherReceivedMemesListPageItemUserDto({
    /// User id.
    required String id,

    /// User display name.
    required String name,

    /// User friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,

    /// User creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// User update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserDetailsOtherReceivedMemesListPageItemUserDto;

  /// Creates one other-received memes-list item user DTO from JSON.
  factory UserDetailsOtherReceivedMemesListPageItemUserDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOtherReceivedMemesListPageItemUserDtoFromJson(json);
}
