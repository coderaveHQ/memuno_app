import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Callback invoked when one text layer should move by drag delta.
typedef MemeEditorLayerMoveCallback =
    void Function(
      String layerId,
      double deltaX,
      double deltaY,
      Size imageBoundsSize,
    );

/// Preview canvas for the selected meme template and text overlays.
final class MemeEditorCanvas extends StatelessWidget {
  /// Creates the editor canvas widget.
  const MemeEditorCanvas({
    super.key,
    required this.repaintBoundaryKey,
    required this.template,
    required this.layers,
    required this.selectedLayerId,
    required this.showSelectionOverlay,
    required this.onSelectLayer,
    required this.onMoveLayer,
  });

  /// Repaint boundary key used for final image capture.
  final GlobalKey repaintBoundaryKey;

  /// Currently selected meme template.
  final MemeTemplateEntity? template;

  /// All text overlays rendered on top of the template.
  final List<MemeTextLayerEntity> layers;

  /// Currently selected text-layer id.
  final String? selectedLayerId;

  /// Whether selected-layer highlight should be shown.
  final bool showSelectionOverlay;

  /// Called when the user taps one text layer.
  final ValueChanged<String?> onSelectLayer;

  /// Called when the user drags one text layer.
  final MemeEditorLayerMoveCallback onMoveLayer;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MemeTemplateEntity? currentTemplate = template;
    if (currentTemplate == null) {
      return ColoredBox(
        color: MColors.gray900,
        child: MCenter(
          child: MText.small(
            text: l10n.memeEditorCanvasSelectTemplateHint,
            style: TextStyle(color: MColors.gray300),
          ),
        ),
      );
    }

    final double safeAspectRatio = currentTemplate.aspectRatio <= 0
        ? 1.0
        : currentTemplate.aspectRatio;

    return ColoredBox(
      color: MColors.gray900,
      child: AspectRatio(
        aspectRatio: safeAspectRatio,
        child: RepaintBoundary(
          key: repaintBoundaryKey,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size canvasSize = constraints.biggest;
              final Rect imageRect = _resolveImageRect(
                canvasSize: canvasSize,
                imageAspectRatio: safeAspectRatio,
              );

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Positioned.fill(
                    child: Image.network(
                      currentTemplate.signedImageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const MCenter(
                              child: MCircularProgressIndicator(),
                            );
                          },
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return MCenter(
                              child: MText.small(
                                text: l10n.memeEditorCanvasImageLoadError,
                                style: TextStyle(color: MColors.gray300),
                              ),
                            );
                          },
                    ),
                  ),
                  for (final MemeTextLayerEntity layer in layers)
                    Builder(
                      builder: (BuildContext context) {
                        final double layerLeft =
                            imageRect.left + layer.positionX * imageRect.width;
                        final double layerTop =
                            imageRect.top + layer.positionY * imageRect.height;
                        final Size layerSize = _measureLayerSize(
                          context,
                          layer: layer,
                        );

                        return Positioned(
                          left: layerLeft,
                          top: layerTop,
                          child: GestureDetector(
                            onTap: () => onSelectLayer(layer.id),
                            onPanStart: (_) => onSelectLayer(layer.id),
                            onPanUpdate: (DragUpdateDetails details) {
                              if (imageRect.width <= 0.0 ||
                                  imageRect.height <= 0.0) {
                                return;
                              }

                              final double minLeft = imageRect.left;
                              final double maxLeft =
                                  (imageRect.right - layerSize.width) < minLeft
                                  ? minLeft
                                  : imageRect.right - layerSize.width;
                              final double minTop = imageRect.top;
                              final double maxTop =
                                  (imageRect.bottom - layerSize.height) < minTop
                                  ? minTop
                                  : imageRect.bottom - layerSize.height;

                              final double nextLeft =
                                  (layerLeft + details.delta.dx).clamp(
                                    minLeft,
                                    maxLeft,
                                  );
                              final double nextTop =
                                  (layerTop + details.delta.dy).clamp(
                                    minTop,
                                    maxTop,
                                  );

                              onMoveLayer(
                                layer.id,
                                nextLeft - layerLeft,
                                nextTop - layerTop,
                                imageRect.size,
                              );
                            },
                            child: _MemeEditorTextLayer(
                              layer: layer,
                              isSelected: selectedLayerId == layer.id,
                              showSelectionOverlay: showSelectionOverlay,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Computes the rendered template rect for `BoxFit.contain`.
  Rect _resolveImageRect({
    required Size canvasSize,
    required double imageAspectRatio,
  }) {
    if (canvasSize.width <= 0.0 || canvasSize.height <= 0.0) {
      return Rect.zero;
    }

    final Size inputSize = Size(imageAspectRatio, 1.0);
    final FittedSizes fittedSizes = applyBoxFit(
      BoxFit.contain,
      inputSize,
      canvasSize,
    );
    final Size destinationSize = fittedSizes.destination;

    return Rect.fromLTWH(
      (canvasSize.width - destinationSize.width) / 2.0,
      (canvasSize.height - destinationSize.height) / 2.0,
      destinationSize.width,
      destinationSize.height,
    );
  }

  /// Measures rendered text size for one meme layer.
  Size _measureLayerSize(
    BuildContext context, {
    required MemeTextLayerEntity layer,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: layer.text.isEmpty ? ' ' : layer.text,
        style: _layerTextStyle(layer),
      ),
      textDirection: Directionality.of(context),
    )..layout();

    return painter.size;
  }
}

/// One rendered text-layer widget on the meme canvas.
final class _MemeEditorTextLayer extends StatelessWidget {
  /// Creates one rendered text-layer widget.
  const _MemeEditorTextLayer({
    required this.layer,
    required this.isSelected,
    required this.showSelectionOverlay,
  });

  /// Text-layer entity rendered by this widget.
  final MemeTextLayerEntity layer;

  /// Whether this layer is currently selected.
  final bool isSelected;

  /// Whether selected-layer highlight should be shown.
  final bool showSelectionOverlay;

  @override
  Widget build(BuildContext context) {
    final bool showSelectedDecoration = showSelectionOverlay && isSelected;

    return Container(
      padding: showSelectedDecoration
          ? const EdgeInsets.symmetric(horizontal: MSpacing.xs, vertical: 2.0)
          : EdgeInsets.zero,
      decoration: showSelectedDecoration
          ? BoxDecoration(
              color: MColors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: MColors.gray100, width: 1.0),
            )
          : null,
      child: Text(
        layer.text.isEmpty ? ' ' : layer.text,
        style: _layerTextStyle(layer),
      ),
    );
  }
}

/// Returns the shared text style used for meme text overlays.
TextStyle _layerTextStyle(MemeTextLayerEntity layer) {
  return TextStyle(
    fontSize: layer.fontSize,
    color: MColors.white,
    fontWeight: FontWeight.w800,
    shadows: const <Shadow>[
      Shadow(offset: Offset(-1.0, -1.0), blurRadius: 1.0),
      Shadow(offset: Offset(1.0, -1.0), blurRadius: 1.0),
      Shadow(offset: Offset(-1.0, 1.0), blurRadius: 1.0),
      Shadow(offset: Offset(1.0, 1.0), blurRadius: 1.0),
    ],
  );
}
