import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Repository contract for local meme-editor state transitions.
abstract class MemeEditorRepository {
  /// Applies a selected [template] and resets the editing draft.
  MemeEditorStateEntity setTemplate({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Template selected by the user.
    required MemeTemplateListPageItemEntity template,
  });

  /// Adds a new text layer and selects it.
  MemeEditorStateEntity addTextLayer({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Initial text rendered by the new layer.
    required String initialText,

    /// Horizontal center position normalized between 0.0 and 1.0.
    required double positionX,

    /// Vertical center position normalized between 0.0 and 1.0.
    required double positionY,
  });

  /// Selects a text layer by [layerId] or clears selection when null.
  MemeEditorStateEntity selectTextLayer({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Target layer identifier, or `null` to clear selection.
    required String? layerId,
  });

  /// Updates text of the currently selected layer.
  MemeEditorStateEntity updateSelectedText({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Updated text for the selected layer.
    required String text,
  });

  /// Updates transform fields of one text layer.
  MemeEditorStateEntity updateTextLayerTransform({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Layer identifier to update.
    required String layerId,

    /// Next horizontal center position normalized between 0.0 and 1.0.
    required double positionX,

    /// Next vertical center position normalized between 0.0 and 1.0.
    required double positionY,

    /// Next font size for the target layer.
    required double fontSize,

    /// Next clockwise rotation in radians for the target layer.
    required double rotationRadians,
  });

  /// Removes one text layer identified by [layerId] when available.
  MemeEditorStateEntity removeTextLayerById({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Layer identifier to remove.
    required String layerId,
  });

  /// Stores finalized PNG bytes in editor state.
  MemeEditorStateEntity setFinalizedImageBytes({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Finalized meme bytes.
    required Uint8List bytes,
  });

  /// Toggles selected-recipient state for one friendship [userId].
  MemeEditorStateEntity toggleRecipientSelection({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Friendship-user identifier to toggle.
    required String userId,
  });

  /// Clears all selected friendship recipients.
  MemeEditorStateEntity clearRecipientSelection({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  });

  /// Updates text color of the currently selected text layer.
  MemeEditorStateEntity updateSelectedTextColor({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Next text ARGB color value.
    required int colorValue,
  });

  /// Toggles text-outline visibility of the selected text layer.
  MemeEditorStateEntity toggleSelectedTextBackground({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  });
}
