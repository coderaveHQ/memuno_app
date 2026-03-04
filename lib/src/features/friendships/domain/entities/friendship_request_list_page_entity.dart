import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';

part 'friendship_request_list_page_entity.freezed.dart';

/// Domain entity matching `public.friendship_request_list_page`.
@freezed
sealed class FriendshipRequestListPageEntity
    with _$FriendshipRequestListPageEntity {
  /// Creates a friendship-request-list page entity.
  const factory FriendshipRequestListPageEntity({
    /// Page items.
    required List<FriendshipRequestListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _FriendshipRequestListPageEntity;

  const FriendshipRequestListPageEntity._();
}
