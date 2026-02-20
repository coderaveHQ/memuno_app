import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Datasource contract for local meme-editor state operations.
abstract class MemeEditorDatasource {
  /// Applies selected [template] and resets draft state.
  MemeEditorStateEntity setTemplate({
    required MemeEditorStateEntity state,
    required MemeTemplateEntity template,
  });

  /// Adds a new text layer with [initialText] and selects it.
  MemeEditorStateEntity addTextLayer({
    required MemeEditorStateEntity state,
    required String initialText,
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

  /// Updates selected-layer font size.
  MemeEditorStateEntity updateSelectedFontSize({
    required MemeEditorStateEntity state,
    required double fontSize,
  });

  /// Moves one text layer by drag delta in canvas coordinates.
  MemeEditorStateEntity moveTextLayerBy({
    required MemeEditorStateEntity state,
    required String layerId,
    required double deltaX,
    required double deltaY,
    required double canvasWidth,
    required double canvasHeight,
  });

  /// Removes selected text layer when available.
  MemeEditorStateEntity removeSelectedTextLayer({
    required MemeEditorStateEntity state,
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
}
