import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_list_page_item_user_entity.freezed.dart';

/// Domain entity matching `public.feed_list_page_item_user`.
@freezed
sealed class FeedListPageItemUserEntity with _$FeedListPageItemUserEntity {
  /// Creates one feed-list item user entity.
  const factory FeedListPageItemUserEntity({
    /// User id from `public.users.id`.
    required String id,

    /// User display name from `public.users.name`.
    required String name,

    /// Friendship code from `public.users.friendship_code`.
    required String friendshipCode,

    /// User creation timestamp.
    required DateTime createdAt,

    /// User update timestamp.
    required DateTime updatedAt,
  }) = _FeedListPageItemUserEntity;

  const FeedListPageItemUserEntity._();
}
