import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Repository contract for local meme-editor state transitions.
abstract class MemeEditorRepository {
  /// Applies a selected [template] and resets the editing draft.
  MemeEditorStateEntity setTemplate({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Template selected by the user.
    required MemeTemplateEntity template,
  });

  /// Applies a selected custom gallery image and resets the editing draft.
  MemeEditorStateEntity setCustomTemplateImage({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// PNG bytes of the selected custom image.
    required Uint8List imageBytes,

    /// Aspect ratio (`width / height`) of [imageBytes].
    required double aspectRatio,
  });

  /// Adds a new text layer and selects it.
  MemeEditorStateEntity addTextLayer({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Initial text rendered by the new layer.
    required String initialText,
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

  /// Updates font size of the currently selected layer.
  MemeEditorStateEntity updateSelectedFontSize({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Updated font size for the selected layer.
    required double fontSize,
  });

  /// Moves a layer by drag delta in canvas coordinates.
  MemeEditorStateEntity moveTextLayerBy({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Layer identifier to update.
    required String layerId,

    /// Horizontal drag delta in logical pixels.
    required double deltaX,

    /// Vertical drag delta in logical pixels.
    required double deltaY,

    /// Rendered canvas width in logical pixels.
    required double canvasWidth,

    /// Rendered canvas height in logical pixels.
    required double canvasHeight,
  });

  /// Removes the currently selected text layer.
  MemeEditorStateEntity removeSelectedTextLayer({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
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

  /// Downscales selected custom image until it fits [maxImageBytes].
  MemeEditorStateEntity optimizeCustomTemplateImageForUpload({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Maximum allowed byte size for selected custom image PNG payload.
    required int maxImageBytes,
  });
}
