import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';

/// Validation helpers for meme-editor input operations.
final class MemeEditorValidator {
  /// Creates a validator instance.
  const MemeEditorValidator();

  /// Maximum length allowed for one text layer.
  static const int maxTextLength = 60;

  /// Minimum font size supported by the editor.
  static const double minFontSize = 18.0;

  /// Maximum font size supported by the editor.
  static const double maxFontSize = 64.0;

  /// Maximum combined bytes allowed for image payload and meme text.
  static const int maxCombinedMemePayloadBytes = 5 * 1024 * 1024;

  /// Validates one text-layer value.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateTextLayerText(String text) {
    if (text.length <= maxTextLength) {
      return null;
    }

    return const Failure.validation(
      code: 'max_length',
      field: 'meme_text',
      params: <String, Object?>{'max': maxTextLength},
    );
  }

  /// Validates selected text-layer identifier.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateLayerId(String layerId) {
    if (layerId.trim().isNotEmpty) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'text_layer_id',
    );
  }

  /// Validates text-layer font size.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateFontSize(double fontSize) {
    if (fontSize >= minFontSize && fontSize <= maxFontSize) {
      return null;
    }

    return const Failure.validation(code: 'invalid_format', field: 'font_size');
  }

  /// Validates rendered canvas dimensions.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateCanvasDimensions({
    required double width,
    required double height,
  }) {
    if (width > 0.0 && height > 0.0) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'canvas_size',
    );
  }

  /// Validates whether any meme background is currently selected.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateTemplateSelected(MemeEditorStateEntity state) {
    if (state.hasBackground) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'meme_background',
    );
  }

  /// Validates finalized PNG bytes.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateFinalizedBytes(Uint8List bytes) {
    if (bytes.isNotEmpty) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'finalized_bytes',
    );
  }

  /// Validates friendship user identifiers used for send selection.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateFriendUserId(String userId) {
    if (userId.trim().isNotEmpty) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'friend_user_id',
    );
  }

  /// Validates meme template identifier.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateTemplateId(String templateId) {
    if (templateId.trim().isNotEmpty) {
      return null;
    }

    return const Failure.validation(code: 'invalid_format', field: 'template');
  }

  /// Validates recipient-user identifier collection.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateRecipientUserIds(Set<String> recipientUserIds) {
    if (recipientUserIds.isNotEmpty) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'recipient_ids',
    );
  }

  /// Validates positive image aspect ratio.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateAspectRatio(double aspectRatio) {
    if (aspectRatio > 0.0) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'image_aspect_ratio',
    );
  }

  /// Validates selected custom-image bytes.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateSelectedImageBytes(Uint8List imageBytes) {
    if (imageBytes.isNotEmpty) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'custom_template_image',
    );
  }

  /// Validates combined byte size for meme image and text payload.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateCombinedPayloadBytes({
    required int imageBytes,
    required int textBytes,
  }) {
    final int total = imageBytes + textBytes;
    if (total <= maxCombinedMemePayloadBytes) {
      return null;
    }

    return const Failure.validation(
      code: 'meme_payload_too_large',
      field: 'meme_payload',
      params: <String, Object?>{'max_bytes': maxCombinedMemePayloadBytes},
    );
  }
}
