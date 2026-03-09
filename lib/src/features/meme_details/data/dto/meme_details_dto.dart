// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_user_dto.dart';

part 'meme_details_dto.freezed.dart';
part 'meme_details_dto.g.dart';

/// DTO matching `public.meme_details`.
@freezed
sealed class MemeDetailsDto with _$MemeDetailsDto {
  /// Creates one meme-details DTO.
  const factory MemeDetailsDto({
    /// Meme id.
    required String id,

    /// Meme creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Meme update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Storage path of the original meme image.
    @JsonKey(name: 'image_path') required String imagePath,

    /// Persisted aspect ratio for display layout.
    @JsonKey(name: 'aspect_ratio') required double aspectRatio,

    /// Total number of laughs for this meme.
    @JsonKey(name: 'laugh_count') required int laughCount,

    /// Whether the current user has laughed this meme.
    @JsonKey(name: 'is_laughed') required bool isLaughed,

    /// Nested creator user payload.
    required MemeDetailsUserDto user,

    /// Signed URL generated client-side for private image access.
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? signedImageUrl,
  }) = _MemeDetailsDto;

  /// Creates one meme-details DTO from JSON.
  factory MemeDetailsDto.fromJson(Map<String, Object?> json) =>
      _$MemeDetailsDtoFromJson(json);
}
