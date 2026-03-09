import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_user_entity.dart';

part 'meme_laugh_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.meme_laugh_list_page_item`.
@freezed
sealed class MemeLaughListPageItemEntity with _$MemeLaughListPageItemEntity {
  /// Creates one meme-laugh-list item entity.
  const factory MemeLaughListPageItemEntity({
    /// Nested laughed user payload.
    required MemeLaughListPageItemUserEntity user,

    /// Laugh creation timestamp.
    required DateTime createdAt,

    /// Laugh update timestamp.
    required DateTime updatedAt,
  }) = _MemeLaughListPageItemEntity;

  const MemeLaughListPageItemEntity._();
}
