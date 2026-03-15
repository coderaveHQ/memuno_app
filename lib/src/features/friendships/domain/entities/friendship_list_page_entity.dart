import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';

part 'friendship_list_page_entity.freezed.dart';

/// Domain entity matching `public.friendship_list_page`.
@freezed
sealed class FriendshipListPageEntity with _$FriendshipListPageEntity {
  /// Creates a friendship-list page entity.
  const factory FriendshipListPageEntity({
    /// Page items.
    required List<FriendshipListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _FriendshipListPageEntity;

  const FriendshipListPageEntity._();
}
