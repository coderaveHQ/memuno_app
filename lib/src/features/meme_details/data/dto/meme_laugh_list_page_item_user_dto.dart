// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_laugh_list_page_item_user_dto.freezed.dart';
part 'meme_laugh_list_page_item_user_dto.g.dart';

/// DTO matching `public.meme_laugh_list_page_item_user`.
@freezed
sealed class MemeLaughListPageItemUserDto with _$MemeLaughListPageItemUserDto {
  /// Creates one meme-laugh-list item user DTO.
  const factory MemeLaughListPageItemUserDto({
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
  }) = _MemeLaughListPageItemUserDto;

  /// Creates one meme-laugh-list item user DTO from JSON.
  factory MemeLaughListPageItemUserDto.fromJson(Map<String, Object?> json) =>
      _$MemeLaughListPageItemUserDtoFromJson(json);
}
