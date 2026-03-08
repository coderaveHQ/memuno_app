import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_entity.dart';

part 'feed_list_page_entity.freezed.dart';

/// Domain entity matching `public.feed_list_page`.
@freezed
sealed class FeedListPageEntity with _$FeedListPageEntity {
  /// Creates one feed-list page entity.
  const factory FeedListPageEntity({
    /// Page items.
    required List<FeedListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _FeedListPageEntity;

  const FeedListPageEntity._();
}
