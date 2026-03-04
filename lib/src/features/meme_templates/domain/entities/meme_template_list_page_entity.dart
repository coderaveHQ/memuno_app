import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

part 'meme_template_list_page_entity.freezed.dart';

/// Domain entity matching `public.meme_template_list_page`.
@freezed
sealed class MemeTemplateListPageEntity with _$MemeTemplateListPageEntity {
  /// Creates a meme-template-list page entity.
  const factory MemeTemplateListPageEntity({
    /// Page items.
    required List<MemeTemplateListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _MemeTemplateListPageEntity;

  const MemeTemplateListPageEntity._();
}
