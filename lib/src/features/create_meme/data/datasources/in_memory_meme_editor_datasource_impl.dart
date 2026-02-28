import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// In-memory implementation for local meme-editor state operations.
final class InMemoryMemeEditorDatasourceImpl implements MemeEditorDatasource {
  /// Creates the datasource.
  InMemoryMemeEditorDatasourceImpl({Random? random})
    : _random = random ?? Random();

  static const double _maxNormalizedPosition = 1.0;
  static const double _basePositionX = 0.08;
  static const double _basePositionY = 0.16;
  static const double _layerVerticalOffset = 0.08;
  static const double _minStaggerY = 0.05;
  static const double _maxStaggerY = 0.85;
  static const double _initialFontSize = 34.0;
  static const double _resizeStepFactor = 0.9;
  static const int _minOptimizedDimension = 128;

  final Random _random;
  int _layerCounter = 0;

  @override
  MemeEditorStateEntity setTemplate({
    required MemeEditorStateEntity state,
    required MemeTemplateEntity template,
  }) {
    return MemeEditorStateEntity(
      template: template,
      customTemplateImageBytes: null,
      customTemplateAspectRatio: null,
      textLayers: const <MemeTextLayerEntity>[],
      selectedTextLayerId: null,
      selectedRecipientUserIds: const <String>{},
      finalizedImageBytes: null,
    );
  }

  @override
  MemeEditorStateEntity setCustomTemplateImage({
    required MemeEditorStateEntity state,
    required Uint8List imageBytes,
    required double aspectRatio,
  }) {
    return MemeEditorStateEntity(
      template: null,
      customTemplateImageBytes: imageBytes,
      customTemplateAspectRatio: aspectRatio,
      textLayers: const <MemeTextLayerEntity>[],
      selectedTextLayerId: null,
      selectedRecipientUserIds: const <String>{},
      finalizedImageBytes: null,
    );
  }

  @override
  MemeEditorStateEntity addTextLayer({
    required MemeEditorStateEntity state,
    required String initialText,
  }) {
    final double staggerY =
        (_basePositionY + state.textLayers.length * _layerVerticalOffset).clamp(
          _minStaggerY,
          _maxStaggerY,
        );

    final MemeTextLayerEntity newLayer = MemeTextLayerEntity(
      id: _nextLayerId(),
      text: initialText,
      positionX: _basePositionX,
      positionY: staggerY,
      fontSize: _initialFontSize,
    );

    return state.copyWith(
      textLayers: List<MemeTextLayerEntity>.unmodifiable(<MemeTextLayerEntity>[
        ...state.textLayers,
        newLayer,
      ]),
      selectedTextLayerId: newLayer.id,
      finalizedImageBytes: null,
    );
  }

  @override
  MemeEditorStateEntity selectTextLayer({
    required MemeEditorStateEntity state,
    required String? layerId,
  }) {
    final String? targetLayerId = layerId;
    if (targetLayerId == null) {
      return state.copyWith(selectedTextLayerId: null);
    }

    final bool exists = state.textLayers.any(
      (MemeTextLayerEntity layer) => layer.id == targetLayerId,
    );
    if (!exists) {
      return state;
    }

    return state.copyWith(selectedTextLayerId: targetLayerId);
  }

  @override
  MemeEditorStateEntity updateSelectedText({
    required MemeEditorStateEntity state,
    required String text,
  }) {
    final MemeTextLayerEntity? selected = state.selectedTextLayer;
    if (selected == null || selected.text == text) {
      return state;
    }

    return _updateLayer(
      state: state,
      layerId: selected.id,
      updater: (MemeTextLayerEntity layer) => layer.copyWith(text: text),
    );
  }

  @override
  MemeEditorStateEntity updateSelectedFontSize({
    required MemeEditorStateEntity state,
    required double fontSize,
  }) {
    final MemeTextLayerEntity? selected = state.selectedTextLayer;
    if (selected == null) {
      return state;
    }

    final double clampedSize = fontSize.clamp(
      MemeEditorValidator.minFontSize,
      MemeEditorValidator.maxFontSize,
    );
    if ((selected.fontSize - clampedSize).abs() < 0.001) {
      return state;
    }

    return _updateLayer(
      state: state,
      layerId: selected.id,
      updater: (MemeTextLayerEntity layer) =>
          layer.copyWith(fontSize: clampedSize),
    );
  }

  @override
  MemeEditorStateEntity moveTextLayerBy({
    required MemeEditorStateEntity state,
    required String layerId,
    required double deltaX,
    required double deltaY,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    if (canvasWidth <= 0.0 || canvasHeight <= 0.0) {
      return state;
    }

    return _updateLayer(
      state: state,
      layerId: layerId,
      updater: (MemeTextLayerEntity layer) {
        final double nextX = (layer.positionX + deltaX / canvasWidth).clamp(
          0.0,
          _maxNormalizedPosition,
        );
        final double nextY = (layer.positionY + deltaY / canvasHeight).clamp(
          0.0,
          _maxNormalizedPosition,
        );
        return layer.copyWith(positionX: nextX, positionY: nextY);
      },
    );
  }

  @override
  MemeEditorStateEntity removeSelectedTextLayer({
    required MemeEditorStateEntity state,
  }) {
    final String? selectedId = state.selectedTextLayerId;
    if (selectedId == null) {
      return state;
    }

    final List<MemeTextLayerEntity> remaining = state.textLayers
        .where((MemeTextLayerEntity layer) => layer.id != selectedId)
        .toList(growable: false);

    return state.copyWith(
      textLayers: List<MemeTextLayerEntity>.unmodifiable(remaining),
      selectedTextLayerId: remaining.isEmpty ? null : remaining.last.id,
      finalizedImageBytes: null,
    );
  }

  @override
  MemeEditorStateEntity setFinalizedImageBytes({
    required MemeEditorStateEntity state,
    required Uint8List bytes,
  }) {
    return state.copyWith(finalizedImageBytes: bytes);
  }

  @override
  MemeEditorStateEntity toggleRecipientSelection({
    required MemeEditorStateEntity state,
    required String userId,
  }) {
    final Set<String> nextSelection = Set<String>.from(
      state.selectedRecipientUserIds,
    );

    if (nextSelection.contains(userId)) {
      nextSelection.remove(userId);
    } else {
      nextSelection.add(userId);
    }

    return state.copyWith(
      selectedRecipientUserIds: Set<String>.unmodifiable(nextSelection),
    );
  }

  @override
  MemeEditorStateEntity clearRecipientSelection({
    required MemeEditorStateEntity state,
  }) {
    if (state.selectedRecipientUserIds.isEmpty) {
      return state;
    }

    return state.copyWith(selectedRecipientUserIds: const <String>{});
  }

  @override
  MemeEditorStateEntity optimizeCustomTemplateImageForUpload({
    required MemeEditorStateEntity state,
    required int maxImageBytes,
  }) {
    final Uint8List? selectedImageBytes = state.customTemplateImageBytes;
    if (selectedImageBytes == null ||
        selectedImageBytes.isEmpty ||
        maxImageBytes <= 0 ||
        selectedImageBytes.length <= maxImageBytes) {
      return state;
    }

    final img.Image? decodedImage = img.decodeImage(selectedImageBytes);
    if (decodedImage == null) {
      return state;
    }

    img.Image currentImage = decodedImage;
    Uint8List encodedBytes = Uint8List.fromList(img.encodePng(currentImage));

    while (encodedBytes.length > maxImageBytes &&
        currentImage.width > _minOptimizedDimension &&
        currentImage.height > _minOptimizedDimension) {
      final int nextWidth = max(
        (currentImage.width * _resizeStepFactor).round(),
        _minOptimizedDimension,
      );
      final int nextHeight = max(
        (currentImage.height * _resizeStepFactor).round(),
        _minOptimizedDimension,
      );

      if (nextWidth == currentImage.width &&
          nextHeight == currentImage.height) {
        break;
      }

      currentImage = img.copyResize(
        currentImage,
        width: nextWidth,
        height: nextHeight,
        interpolation: img.Interpolation.average,
      );
      encodedBytes = Uint8List.fromList(img.encodePng(currentImage));
    }

    if (encodedBytes.length > maxImageBytes) {
      return state;
    }

    final double aspectRatio = currentImage.height == 0
        ? (state.customTemplateAspectRatio ?? 1.0)
        : currentImage.width / currentImage.height;

    return state.copyWith(
      customTemplateImageBytes: encodedBytes,
      customTemplateAspectRatio: aspectRatio,
      finalizedImageBytes: null,
    );
  }

  String _nextLayerId() {
    _layerCounter += 1;
    final int randomPart = _random.nextInt(1 << 32);
    return 'layer_${DateTime.now().microsecondsSinceEpoch}_${_layerCounter}_$randomPart';
  }

  MemeEditorStateEntity _updateLayer({
    required MemeEditorStateEntity state,
    required String layerId,
    required MemeTextLayerEntity Function(MemeTextLayerEntity layer) updater,
  }) {
    bool hasChanged = false;

    final List<MemeTextLayerEntity> nextLayers = state.textLayers
        .map((MemeTextLayerEntity layer) {
          if (layer.id != layerId) {
            return layer;
          }

          hasChanged = true;
          return updater(layer);
        })
        .toList(growable: false);

    if (!hasChanged) {
      return state;
    }

    return state.copyWith(
      textLayers: List<MemeTextLayerEntity>.unmodifiable(nextLayers),
      finalizedImageBytes: null,
    );
  }
}
