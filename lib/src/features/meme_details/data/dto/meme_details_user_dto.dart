// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_details_user_dto.freezed.dart';
part 'meme_details_user_dto.g.dart';

/// DTO matching `public.meme_details_user`.
@freezed
sealed class MemeDetailsUserDto with _$MemeDetailsUserDto {
  /// Creates one meme-details user DTO.
  const factory MemeDetailsUserDto({
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
  }) = _MemeDetailsUserDto;

  /// Creates one meme-details user DTO from JSON.
  factory MemeDetailsUserDto.fromJson(Map<String, Object?> json) =>
      _$MemeDetailsUserDtoFromJson(json);
}
