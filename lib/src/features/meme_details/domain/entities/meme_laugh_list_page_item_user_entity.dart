import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_laugh_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.meme_laugh_list_page_item_user`.
@freezed
sealed class MemeLaughListPageItemUserEntity
    with _$MemeLaughListPageItemUserEntity {
  /// Creates one meme-laugh-list item user entity.
  const factory MemeLaughListPageItemUserEntity({
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
  }) = _MemeLaughListPageItemUserEntity;

  const MemeLaughListPageItemUserEntity._();
}
