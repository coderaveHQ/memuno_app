// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

/// Data transfer object for current-user profile records.
@freezed
sealed class UserProfileDto with _$UserProfileDto {
  /// Creates a profile DTO.
  const factory UserProfileDto({
    /// User id.
    required String id,

    /// App-level display name.
    required String name,

    /// 8-digit friendship code.
    @JsonKey(name: 'friendship_code') required String friendshipCode,

    /// Profile creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Profile update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserProfileDto;

  /// Builds a DTO from JSON.
  factory UserProfileDto.fromJson(Map<String, Object?> json) =>
      _$UserProfileDtoFromJson(json);
}
