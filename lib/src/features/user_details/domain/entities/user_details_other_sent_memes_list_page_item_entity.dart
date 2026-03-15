import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_user_entity.dart';

part 'user_details_other_sent_memes_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_sent_memes_list_page_item`.
@freezed
sealed class UserDetailsOtherSentMemesListPageItemEntity
    with _$UserDetailsOtherSentMemesListPageItemEntity {
  /// Creates one other-sent memes-list item entity.
  const factory UserDetailsOtherSentMemesListPageItemEntity({
    /// Nested meme payload.
    required UserDetailsOtherSentMemesListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required UserDetailsOtherSentMemesListPageItemUserEntity user,
  }) = _UserDetailsOtherSentMemesListPageItemEntity;

  const UserDetailsOtherSentMemesListPageItemEntity._();
}
