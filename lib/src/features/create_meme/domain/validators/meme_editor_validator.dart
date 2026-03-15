import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';

/// Validation helpers for meme-editor input operations.
final class MemeEditorValidator {
  /// Creates a validator instance.
  const MemeEditorValidator();

  /// Minimum font size supported by the editor.
  static const double minFontSize = 18.0;

  /// Maximum font size supported by the editor.
  static const double maxFontSize = 64.0;

  /// Lower inclusive bound for valid ARGB color values.
  static const int minColorValue = 0x00000000;

  /// Upper inclusive bound for valid ARGB color values.
  static const int maxColorValue = 0xFFFFFFFF;

  /// Validates one text-layer value.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateTextLayerText(String text) {
    return null;
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

  /// Validates whether any meme background is currently selected.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateTemplateSelected(MemeEditorStateEntity state) {
    if (state.hasTemplate) {
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

  /// Validates one normalized layer coordinate.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateNormalizedPosition(double value) {
    if (value.isFinite && value >= 0.0 && value <= 1.0) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'normalized_position',
    );
  }

  /// Validates one finite rotation value in radians.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateRotationRadians(double rotationRadians) {
    if (rotationRadians.isFinite) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'rotation_radians',
    );
  }

  /// Validates one ARGB color integer.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateColorValue(int colorValue) {
    if (colorValue >= minColorValue && colorValue <= maxColorValue) {
      return null;
    }

    return const Failure.validation(code: 'invalid_format', field: 'color');
  }

  /// Validates positive image width and height values.
  ///
  /// Returns a [Failure.validation] when invalid, otherwise `null`.
  Failure? validateImageSize(MemeImageSizeEntity size) {
    if (size.width > 0 && size.height > 0) {
      return null;
    }

    return const Failure.validation(
      code: 'invalid_format',
      field: 'image_size',
    );
  }
}
