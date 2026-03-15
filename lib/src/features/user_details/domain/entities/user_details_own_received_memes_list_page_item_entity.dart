import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_item_user_entity.dart';

part 'user_details_own_received_memes_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_received_memes_list_page_item`.
@freezed
sealed class UserDetailsOwnReceivedMemesListPageItemEntity
    with _$UserDetailsOwnReceivedMemesListPageItemEntity {
  /// Creates one own-received memes-list item entity.
  const factory UserDetailsOwnReceivedMemesListPageItemEntity({
    /// Nested meme payload.
    required UserDetailsOwnReceivedMemesListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required UserDetailsOwnReceivedMemesListPageItemUserEntity user,
  }) = _UserDetailsOwnReceivedMemesListPageItemEntity;

  const UserDetailsOwnReceivedMemesListPageItemEntity._();
}
