// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_dto.freezed.dart';
part 'user_details_dto.g.dart';

/// Data transfer object for user-details records.
@freezed
sealed class UserDetailsDto with _$UserDetailsDto {
  /// Creates a user-details DTO.
  const factory UserDetailsDto({
    /// User id.
    required String id,

    /// App-level display name.
    required String name,

    /// 8-digit friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,

    /// User-details creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// User-details update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserDetailsDto;

  /// Builds a DTO from JSON.
  factory UserDetailsDto.fromJson(Map<String, Object?> json) =>
      _$UserDetailsDtoFromJson(json);
}
