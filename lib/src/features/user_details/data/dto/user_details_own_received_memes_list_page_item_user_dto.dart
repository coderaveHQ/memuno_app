// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_received_memes_list_page_item_user_dto.freezed.dart';
part 'user_details_own_received_memes_list_page_item_user_dto.g.dart';

/// DTO matching `public.user_details_own_received_memes_list_page_item_user`.
@freezed
sealed class UserDetailsOwnReceivedMemesListPageItemUserDto
    with _$UserDetailsOwnReceivedMemesListPageItemUserDto {
  /// Creates one own-received memes-list item user DTO.
  const factory UserDetailsOwnReceivedMemesListPageItemUserDto({
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
  }) = _UserDetailsOwnReceivedMemesListPageItemUserDto;

  /// Creates one own-received memes-list item user DTO from JSON.
  factory UserDetailsOwnReceivedMemesListPageItemUserDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnReceivedMemesListPageItemUserDtoFromJson(json);
}
