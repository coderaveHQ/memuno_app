import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_entity.dart';

part 'user_details_other_received_memes_list_page_entity.freezed.dart';

/// Domain entity matching `public.user_details_other_received_memes_list_page`.
@freezed
sealed class UserDetailsOtherReceivedMemesListPageEntity
    with _$UserDetailsOtherReceivedMemesListPageEntity {
  /// Creates one other-received memes-list page entity.
  const factory UserDetailsOtherReceivedMemesListPageEntity({
    /// Page items.
    required List<UserDetailsOtherReceivedMemesListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _UserDetailsOtherReceivedMemesListPageEntity;

  const UserDetailsOtherReceivedMemesListPageEntity._();
}
