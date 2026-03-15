import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_own_sent_memes_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_sent_memes_list_page_item_user`.
@freezed
sealed class UserDetailsOwnSentMemesListPageItemUserEntity
    with _$UserDetailsOwnSentMemesListPageItemUserEntity {
  /// Creates one own-sent memes-list item user entity.
  const factory UserDetailsOwnSentMemesListPageItemUserEntity({
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
  }) = _UserDetailsOwnSentMemesListPageItemUserEntity;

  const UserDetailsOwnSentMemesListPageItemUserEntity._();
}
