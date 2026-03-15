import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_entity.dart';

part 'user_details_other_sent_memes_list_page_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_sent_memes_list_page`.
@freezed
sealed class UserDetailsOtherSentMemesListPageEntity
    with _$UserDetailsOtherSentMemesListPageEntity {
  /// Creates one other-sent memes-list page entity.
  const factory UserDetailsOtherSentMemesListPageEntity({
    /// Page items.
    required List<UserDetailsOtherSentMemesListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _UserDetailsOtherSentMemesListPageEntity;

  const UserDetailsOtherSentMemesListPageEntity._();
}
