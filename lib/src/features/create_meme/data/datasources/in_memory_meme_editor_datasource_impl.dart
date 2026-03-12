import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// In-memory implementation for local meme-editor state operations.
final class InMemoryMemeEditorDatasourceImpl implements MemeEditorDatasource {
  /// Creates the datasource.
  InMemoryMemeEditorDatasourceImpl({Random? random})
    : _random = random ?? Random();

  static const double _maxNormalizedPosition = 1.0;
  static const double _minNormalizedPosition = 0.0;
  static const double _initialFontSize = 34.0;
  static const double _initialRotation = 0.0;
  static const int _whiteTextColorValue = 0xFFFFFFFF;
  static const int _blackTextColorValue = 0xFF000000;
  static const int _defaultTextColorValue = _whiteTextColorValue;
  static const bool _defaultHasBackground = false;
  static const int _defaultBackgroundColorValue = _blackTextColorValue;
  static const double _resizeStepFactor = 0.9;
  static const int _minOptimizedDimension = 128;

  final Random _random;
  int _layerCounter = 0;

  @override
  MemeEditorStateEntity setTemplate({
    required MemeEditorStateEntity state,
    required MemeTemplateListPageItemEntity template,
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
    required double positionX,
    required double positionY,
  }) {
    final MemeTextLayerEntity newLayer = MemeTextLayerEntity(
      id: _nextLayerId(),
      text: initialText,
      positionX: _clampNormalized(positionX),
      positionY: _clampNormalized(positionY),
      fontSize: _initialFontSize,
      rotationRadians: _initialRotation,
      textColorValue: _defaultTextColorValue,
      hasBackground: _defaultHasBackground,
      backgroundColorValue: _defaultBackgroundColorValue,
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
  MemeEditorStateEntity updateTextLayerTransform({
    required MemeEditorStateEntity state,
    required String layerId,
    required double positionX,
    required double positionY,
    required double fontSize,
    required double rotationRadians,
  }) {
    return _updateLayer(
      state: state,
      layerId: layerId,
      updater: (MemeTextLayerEntity layer) {
        return layer.copyWith(
          positionX: _clampNormalized(positionX),
          positionY: _clampNormalized(positionY),
          fontSize: fontSize.clamp(
            MemeEditorValidator.minFontSize,
            MemeEditorValidator.maxFontSize,
          ),
          rotationRadians: rotationRadians,
        );
      },
    );
  }

  @override
  MemeEditorStateEntity removeTextLayerById({
    required MemeEditorStateEntity state,
    required String layerId,
  }) {
    final bool exists = state.textLayers.any(
      (MemeTextLayerEntity layer) => layer.id == layerId,
    );
    if (!exists) {
      return state;
    }

    final List<MemeTextLayerEntity> remaining = state.textLayers
        .where((MemeTextLayerEntity layer) => layer.id != layerId)
        .toList(growable: false);

    final String? selectedId = state.selectedTextLayerId;
    final bool selectedStillExists =
        selectedId != null &&
        remaining.any((MemeTextLayerEntity layer) => layer.id == selectedId);

    return state.copyWith(
      textLayers: List<MemeTextLayerEntity>.unmodifiable(remaining),
      selectedTextLayerId: selectedStillExists ? selectedId : null,
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
  MemeEditorStateEntity updateSelectedTextColor({
    required MemeEditorStateEntity state,
    required int colorValue,
  }) {
    final MemeTextLayerEntity? selected = state.selectedTextLayer;
    if (selected == null || selected.textColorValue == colorValue) {
      return state;
    }

    return _updateLayer(
      state: state,
      layerId: selected.id,
      updater: (MemeTextLayerEntity layer) {
        if (!layer.hasBackground) {
          return layer.copyWith(textColorValue: colorValue);
        }

        return layer.copyWith(
          textColorValue: colorValue,
          backgroundColorValue: _resolveOppositeOutlineColor(colorValue),
        );
      },
    );
  }

  @override
  MemeEditorStateEntity toggleSelectedTextBackground({
    required MemeEditorStateEntity state,
  }) {
    final MemeTextLayerEntity? selected = state.selectedTextLayer;
    if (selected == null) {
      return state;
    }

    return _updateLayer(
      state: state,
      layerId: selected.id,
      updater: (MemeTextLayerEntity layer) {
        final bool nextHasBackground = !layer.hasBackground;
        return layer.copyWith(
          hasBackground: nextHasBackground,
          backgroundColorValue: nextHasBackground
              ? _resolveOppositeOutlineColor(layer.textColorValue)
              : layer.backgroundColorValue,
        );
      },
    );
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

  double _clampNormalized(double value) {
    return value.clamp(_minNormalizedPosition, _maxNormalizedPosition);
  }

  /// Resolves the opposite outline color for [textColorValue].
  int _resolveOppositeOutlineColor(int textColorValue) {
    return textColorValue == _blackTextColorValue
        ? _whiteTextColorValue
        : _blackTextColorValue;
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

          final MemeTextLayerEntity updatedLayer = updater(layer);
          if (updatedLayer == layer) {
            return layer;
          }
          hasChanged = true;
          return updatedLayer;
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
