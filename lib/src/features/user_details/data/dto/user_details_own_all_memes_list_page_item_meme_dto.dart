// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_all_memes_list_page_item_meme_dto.freezed.dart';
part 'user_details_own_all_memes_list_page_item_meme_dto.g.dart';

/// DTO matching `public.user_details_own_all_memes_list_page_item_meme`.
@freezed
sealed class UserDetailsOwnAllMemesListPageItemMemeDto
    with _$UserDetailsOwnAllMemesListPageItemMemeDto {
  /// Creates one own-all memes-list item meme DTO.
  const factory UserDetailsOwnAllMemesListPageItemMemeDto({
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

    /// Whether the current user has laughed at this meme.
    @JsonKey(name: 'is_laughed') required bool isLaughed,

    /// Signed URL generated client-side for private image access.
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? signedImageUrl,
  }) = _UserDetailsOwnAllMemesListPageItemMemeDto;

  /// Creates one own-all memes-list item meme DTO from JSON.
  factory UserDetailsOwnAllMemesListPageItemMemeDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnAllMemesListPageItemMemeDtoFromJson(json);
}
