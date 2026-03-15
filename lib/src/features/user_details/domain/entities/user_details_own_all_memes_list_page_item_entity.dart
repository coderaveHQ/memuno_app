import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_user_entity.dart';

part 'user_details_own_all_memes_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_all_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnAllMemesListPageItemEntity
    with _$UserDetailsOwnAllMemesListPageItemEntity {
  /// Creates one own-all memes-list item entity.
  const factory UserDetailsOwnAllMemesListPageItemEntity({
    /// Nested meme payload.
    required UserDetailsOwnAllMemesListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required UserDetailsOwnAllMemesListPageItemUserEntity user,
  }) = _UserDetailsOwnAllMemesListPageItemEntity;

  const UserDetailsOwnAllMemesListPageItemEntity._();
}
