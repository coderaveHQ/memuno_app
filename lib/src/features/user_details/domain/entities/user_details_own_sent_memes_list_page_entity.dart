import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_entity.dart';

part 'user_details_own_sent_memes_list_page_entity.freezed.dart';

/// Domain entity matching `public.user_details_own_sent_memes_list_page`.
@freezed
sealed class UserDetailsOwnSentMemesListPageEntity
    with _$UserDetailsOwnSentMemesListPageEntity {
  /// Creates one own-sent memes-list page entity.
  const factory UserDetailsOwnSentMemesListPageEntity({
    /// Page items.
    required List<UserDetailsOwnSentMemesListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _UserDetailsOwnSentMemesListPageEntity;

  const UserDetailsOwnSentMemesListPageEntity._();
}
