import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_user_entity.dart';

part 'user_details_own_sent_memes_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_sent_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnSentMemesListPageItemEntity
    with _$UserDetailsOwnSentMemesListPageItemEntity {
  /// Creates one own-sent memes-list item entity.
  const factory UserDetailsOwnSentMemesListPageItemEntity({
    /// Nested meme payload.
    required UserDetailsOwnSentMemesListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required UserDetailsOwnSentMemesListPageItemUserEntity user,
  }) = _UserDetailsOwnSentMemesListPageItemEntity;

  const UserDetailsOwnSentMemesListPageItemEntity._();
}
