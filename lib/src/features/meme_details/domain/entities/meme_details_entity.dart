import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_user_entity.dart';

part 'meme_details_entity.freezed.dart';

/// Domain entity matching `public.meme_details`.
@freezed
sealed class MemeDetailsEntity with _$MemeDetailsEntity {
  /// Creates one meme-details entity.
  const factory MemeDetailsEntity({
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

    /// Whether the current user has laughed this meme.
    required bool isLaughed,

    /// Nested creator user payload.
    required MemeDetailsUserEntity user,
  }) = _MemeDetailsEntity;

  const MemeDetailsEntity._();
}
