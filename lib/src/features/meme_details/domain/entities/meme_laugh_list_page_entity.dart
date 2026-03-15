import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';

part 'meme_laugh_list_page_entity.freezed.dart';

/// Domain entity matching `public.meme_laugh_list_page`.
@freezed
sealed class MemeLaughListPageEntity with _$MemeLaughListPageEntity {
  /// Creates one meme-laugh-list page entity.
  const factory MemeLaughListPageEntity({
    /// Page items.
    required List<MemeLaughListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _MemeLaughListPageEntity;

  const MemeLaughListPageEntity._();
}
