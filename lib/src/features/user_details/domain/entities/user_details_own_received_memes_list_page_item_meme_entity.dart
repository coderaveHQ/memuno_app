import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_received_memes_list_page_item_meme_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_received_memes_list_page_item_meme`.
@freezed
sealed class UserDetailsOwnReceivedMemesListPageItemMemeEntity
    with _$UserDetailsOwnReceivedMemesListPageItemMemeEntity {
  /// Creates one own-received memes-list item meme entity.
  const factory UserDetailsOwnReceivedMemesListPageItemMemeEntity({
    /// Meme id from `public.memes.id`.
    required String id,

    /// Meme creation timestamp.
    required DateTime createdAt,

    /// Meme update timestamp.
    required DateTime updatedAt,

    /// Frontend-signed URL for rendering private meme images.
    required String signedImageUrl,

    /// Persisted meme aspect ratio from `public.memes.aspect_ratio`.
    required double aspectRatio,

    /// Total number of laughs for this meme.
    required int laughCount,

    /// Whether the current user has laughed at this meme.
    required bool isLaughed,
  }) = _UserDetailsOwnReceivedMemesListPageItemMemeEntity;

  const UserDetailsOwnReceivedMemesListPageItemMemeEntity._();
}
