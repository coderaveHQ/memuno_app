import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_item_entity.dart';

part 'user_details_other_all_memes_list_page_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_all_memes_list_page`.
@freezed
sealed class UserDetailsOtherAllMemesListPageEntity
    with _$UserDetailsOtherAllMemesListPageEntity {
  /// Creates one other-all memes-list page entity.
  const factory UserDetailsOtherAllMemesListPageEntity({
    /// Page items.
    required List<UserDetailsOtherAllMemesListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _UserDetailsOtherAllMemesListPageEntity;

  const UserDetailsOtherAllMemesListPageEntity._();
}
