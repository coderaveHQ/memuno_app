import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_details_user_entity.freezed.dart';

/// Domain entity matching `public.meme_details_user`.
@freezed
sealed class MemeDetailsUserEntity with _$MemeDetailsUserEntity {
  /// Creates one meme-details user entity.
  const factory MemeDetailsUserEntity({
    /// User id from `public.users.id`.
    required String id,

    /// User display name from `public.users.name`.
    required String name,

    /// Friendship code from `public.users.friendship_code`.
    required String friendshipCode,

    /// User creation timestamp.
    required DateTime createdAt,

    /// User update timestamp.
    required DateTime updatedAt,
  }) = _MemeDetailsUserEntity;

  const MemeDetailsUserEntity._();
}
