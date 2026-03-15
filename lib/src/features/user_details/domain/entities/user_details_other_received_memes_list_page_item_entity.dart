import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_user_entity.dart';

part 'user_details_other_received_memes_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_received_memes_list_page_item`.
@freezed
sealed class UserDetailsOtherReceivedMemesListPageItemEntity
    with _$UserDetailsOtherReceivedMemesListPageItemEntity {
  /// Creates one other-received memes-list item entity.
  const factory UserDetailsOtherReceivedMemesListPageItemEntity({
    /// Nested meme payload.
    required UserDetailsOtherReceivedMemesListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required UserDetailsOtherReceivedMemesListPageItemUserEntity user,
  }) = _UserDetailsOtherReceivedMemesListPageItemEntity;

  const UserDetailsOtherReceivedMemesListPageItemEntity._();
}
