import 'package:freezed_annotation/freezed_annotation.dart';

part 'meme_template_cursor_entity.freezed.dart';

/// Cursor payload used by `meme_templates_list` pagination.
@freezed
sealed class MemeTemplateCursorEntity with _$MemeTemplateCursorEntity {
  /// Creates a meme-template cursor entity.
  const factory MemeTemplateCursorEntity({
    /// Last seen creation timestamp in descending cursor pagination.
    required DateTime createdAt,

    /// Stable template identifier used as cursor tie-breaker.
    required String id,
  }) = _MemeTemplateCursorEntity;

  const MemeTemplateCursorEntity._();
}
