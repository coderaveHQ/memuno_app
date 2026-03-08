import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_user_entity.dart';

part 'feed_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.feed_list_page_item`.
@freezed
sealed class FeedListPageItemEntity with _$FeedListPageItemEntity {
  /// Creates one feed-list item entity.
  const factory FeedListPageItemEntity({
    /// Nested meme payload.
    required FeedListPageItemMemeEntity meme,

    /// Nested creator user payload.
    required FeedListPageItemUserEntity user,
  }) = _FeedListPageItemEntity;

  const FeedListPageItemEntity._();
}
