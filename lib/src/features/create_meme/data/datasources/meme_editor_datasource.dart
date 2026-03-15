import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Datasource contract for local meme-editor state operations.
abstract class MemeEditorDatasource {
  /// Applies selected [template] and resets draft state.
  MemeEditorStateEntity setTemplate({
    required MemeEditorStateEntity state,
    required MemeTemplateListPageItemEntity template,
  });

  /// Adds a new text layer with [initialText] and selects it.
  MemeEditorStateEntity addTextLayer({
    required MemeEditorStateEntity state,
    required String initialText,
    required double positionX,
    required double positionY,
  });

  /// Selects a text layer by [layerId] or clears selection when null.
  MemeEditorStateEntity selectTextLayer({
    required MemeEditorStateEntity state,
    required String? layerId,
  });

  /// Updates selected-layer text.
  MemeEditorStateEntity updateSelectedText({
    required MemeEditorStateEntity state,
    required String text,
  });

  /// Updates transform fields of one text layer.
  MemeEditorStateEntity updateTextLayerTransform({
    required MemeEditorStateEntity state,
    required String layerId,
    required double positionX,
    required double positionY,
    required double fontSize,
    required double rotationRadians,
  });

  /// Removes one text layer identified by [layerId] when available.
  MemeEditorStateEntity removeTextLayerById({
    required MemeEditorStateEntity state,
    required String layerId,
  });

  /// Stores finalized PNG bytes.
  MemeEditorStateEntity setFinalizedImageBytes({
    required MemeEditorStateEntity state,
    required Uint8List bytes,
  });

  /// Toggles recipient selection for one friendship [userId].
  MemeEditorStateEntity toggleRecipientSelection({
    required MemeEditorStateEntity state,
    required String userId,
  });

  /// Clears all selected recipients.
  MemeEditorStateEntity clearRecipientSelection({
    required MemeEditorStateEntity state,
  });

  /// Updates text color of the currently selected text layer.
  MemeEditorStateEntity updateSelectedTextColor({
    required MemeEditorStateEntity state,
    required int colorValue,
  });

  /// Toggles outline visibility of the currently selected text layer.
  MemeEditorStateEntity toggleSelectedTextBackground({
    required MemeEditorStateEntity state,
  });
}
