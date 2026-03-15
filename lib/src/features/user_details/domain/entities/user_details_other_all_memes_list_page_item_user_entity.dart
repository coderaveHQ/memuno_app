import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_other_all_memes_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_all_memes_list_page_item_user`.
@freezed
sealed class UserDetailsOtherAllMemesListPageItemUserEntity
    with _$UserDetailsOtherAllMemesListPageItemUserEntity {
  /// Creates one other-all memes-list item user entity.
  const factory UserDetailsOtherAllMemesListPageItemUserEntity({
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
  }) = _UserDetailsOtherAllMemesListPageItemUserEntity;

  const UserDetailsOtherAllMemesListPageItemUserEntity._();
}
