import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Immutable editor state for composing one meme.
final class MemeEditorStateEntity {
  /// Creates a meme-editor state snapshot.
  const MemeEditorStateEntity({
    required this.template,
    required this.textLayers,
    required this.selectedTextLayerId,
    required this.selectedRecipientUserIds,
    required this.finalizedImageBytes,
  });

  /// Sentinel object for nullable `copyWith` fields.
  static const Object _sentinel = Object();

  /// Initial empty state.
  factory MemeEditorStateEntity.initial() {
    return const MemeEditorStateEntity(
      template: null,
      textLayers: <MemeTextLayerEntity>[],
      selectedTextLayerId: null,
      selectedRecipientUserIds: <String>{},
      finalizedImageBytes: null,
    );
  }

  /// Currently selected meme template.
  final MemeTemplateEntity? template;

  /// All text overlays currently placed on the meme.
  final List<MemeTextLayerEntity> textLayers;

  /// Identifier of the currently selected text layer, if any.
  final String? selectedTextLayerId;

  /// Selected friendship-user identifiers for send flow.
  final Set<String> selectedRecipientUserIds;

  /// Last finalized meme bytes produced from the editor, if available.
  final Uint8List? finalizedImageBytes;

  /// Returns the currently selected text layer.
  MemeTextLayerEntity? get selectedTextLayer {
    final String? selectedId = selectedTextLayerId;
    if (selectedId == null) {
      return null;
    }

    for (final MemeTextLayerEntity layer in textLayers) {
      if (layer.id == selectedId) {
        return layer;
      }
    }

    return null;
  }

  /// Returns whether a template is selected.
  bool get hasTemplate => template != null;

  /// Returns whether finalization is possible.
  bool get canFinalize => hasTemplate;

  /// Returns whether one friendship user is selected for sending.
  bool get hasSelectedRecipients => selectedRecipientUserIds.isNotEmpty;

  /// Returns whether [userId] is currently selected.
  bool isRecipientSelected(String userId) {
    return selectedRecipientUserIds.contains(userId);
  }

  /// Returns a new state with updated fields.
  MemeEditorStateEntity copyWith({
    MemeTemplateEntity? template,
    List<MemeTextLayerEntity>? textLayers,
    Object? selectedTextLayerId = _sentinel,
    Object? selectedRecipientUserIds = _sentinel,
    Object? finalizedImageBytes = _sentinel,
  }) {
    return MemeEditorStateEntity(
      template: template ?? this.template,
      textLayers: textLayers ?? this.textLayers,
      selectedTextLayerId: selectedTextLayerId == _sentinel
          ? this.selectedTextLayerId
          : selectedTextLayerId as String?,
      selectedRecipientUserIds: selectedRecipientUserIds == _sentinel
          ? this.selectedRecipientUserIds
          : selectedRecipientUserIds as Set<String>,
      finalizedImageBytes: finalizedImageBytes == _sentinel
          ? this.finalizedImageBytes
          : finalizedImageBytes as Uint8List?,
    );
  }
}
