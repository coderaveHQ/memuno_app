import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_image.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Callback invoked when the user taps one empty canvas area.
typedef MemeEditorCanvasTapCallback =
    void Function(double positionX, double positionY);

/// Callback invoked when one text layer should be focused for editing.
typedef MemeEditorLayerTapCallback = void Function(String layerId);

/// Callback invoked when one drag/pinch gesture starts on a text layer.
typedef MemeEditorLayerGestureStartCallback = void Function(String layerId);

/// Callback invoked when one text layer should be removed.
typedef MemeEditorLayerDeleteCallback = void Function(String layerId);

/// Callback invoked when transform values of one layer should be updated.
typedef MemeEditorLayerTransformCallback =
    void Function(
      String layerId,
      double positionX,
      double positionY,
      double fontSize,
      double rotationRadians,
    );

/// Callback invoked when one outside tap should only dismiss text editing.
typedef MemeEditorDismissEditingCallback = void Function();

/// Scrollable meme-editor canvas with gesture-based text manipulation.
final class MemeEditorCanvas extends StatefulWidget {
  /// Creates the meme-editor canvas.
  const MemeEditorCanvas({
    super.key,
    required this.repaintBoundaryKey,
    required this.scrollController,
    required this.template,
    required this.layers,
    required this.selectedLayerId,
    required this.selectedTextController,
    required this.selectedTextFocusNode,
    required this.isSelectedLayerEditing,
    required this.isTextEditingActive,
    required this.onTapCanvas,
    required this.onTapOutsideWhileEditing,
    required this.onTapLayer,
    required this.onStartLayerTransform,
    required this.onTransformLayer,
    required this.onDeleteLayer,
  });

  /// Repaint boundary key used for final image capture.
  final GlobalKey repaintBoundaryKey;

  /// Vertical controller used by the canvas scroll viewport.
  final ScrollController scrollController;

  /// Currently selected meme template.
  final MemeTemplateListPageItemEntity? template;

  /// All text overlays rendered on top of the template.
  final List<MemeTextLayerEntity> layers;

  /// Currently selected text-layer id.
  final String? selectedLayerId;

  /// Text controller bound to the selected layer.
  final TextEditingController selectedTextController;

  /// Focus node bound to the selected layer.
  final FocusNode selectedTextFocusNode;

  /// Whether the selected layer should render in inline-edit mode.
  final bool isSelectedLayerEditing;

  /// Whether any text layer is currently focused for keyboard editing.
  final bool isTextEditingActive;

  /// Called when the user taps one empty canvas area and a new layer should be added.
  final MemeEditorCanvasTapCallback onTapCanvas;

  /// Called when one outside tap should only dismiss keyboard focus.
  final MemeEditorDismissEditingCallback onTapOutsideWhileEditing;

  /// Called when one text layer is tapped for editing.
  final MemeEditorLayerTapCallback onTapLayer;

  /// Called when one drag/pinch gesture begins on one layer.
  final MemeEditorLayerGestureStartCallback onStartLayerTransform;

  /// Called when the user updates one layer transform.
  final MemeEditorLayerTransformCallback onTransformLayer;

  /// Called when one layer should be deleted.
  final MemeEditorLayerDeleteCallback onDeleteLayer;

  @override
  State<MemeEditorCanvas> createState() => _MemeEditorCanvasState();
}

/// Mutable interaction state for one active canvas transform gesture.
final class _CanvasTransformSession {
  /// Creates one transform session.
  _CanvasTransformSession({
    required this.layerId,
    required this.startFocalPoint,
    required this.currentFocalPoint,
    required this.startCenter,
    required this.currentCenter,
    required this.startFontSize,
    required this.currentFontSize,
    required this.startRotationRadians,
    required this.currentRotationRadians,
    required this.pointerCount,
  });

  /// Identifier of the currently transformed layer.
  final String layerId;

  /// Gesture focal point at scale-start time.
  Offset startFocalPoint;

  /// Last observed gesture focal point in canvas coordinates.
  Offset currentFocalPoint;

  /// Layer center at scale-start time.
  Offset startCenter;

  /// Last applied center in canvas pixels.
  Offset currentCenter;

  /// Layer font size at scale-start time.
  double startFontSize;

  /// Last applied font size.
  double currentFontSize;

  /// Layer rotation at scale-start time.
  double startRotationRadians;

  /// Last applied rotation value.
  double currentRotationRadians;

  /// Latest pointer count used to detect gesture-mode transitions.
  int pointerCount;

  /// Whether rotation is currently snapped to upright orientation.
  bool isRotationSnapped = false;

  /// Whether two-finger baseline geometry is initialized.
  bool hasTwoFingerBaseline = false;

  /// Two-finger span captured at baseline.
  double twoFingerBaselineSpan = 0.0;

  /// Two-finger angle captured at baseline.
  double twoFingerBaselineAngle = 0.0;

  /// Font size captured at two-finger baseline.
  double twoFingerBaselineFontSize = 0.0;

  /// Rotation captured at two-finger baseline.
  double twoFingerBaselineRotationRadians = 0.0;
}

/// Mutable interaction state for one active background-scroll gesture.
final class _CanvasScrollSession {
  /// Creates one background-scroll session.
  const _CanvasScrollSession({
    required this.startFocalPoint,
    required this.startScrollOffset,
  });

  /// Gesture focal point at scale-start time.
  final Offset startFocalPoint;

  /// Scroll offset at scale-start time.
  final double startScrollOffset;
}

/// Two-pointer geometry snapshot used for robust pinch/rotation updates.
final class _TwoPointerGeometry {
  /// Creates one two-pointer geometry snapshot.
  const _TwoPointerGeometry({required this.span, required this.angle});

  /// Distance between two active pointers.
  final double span;

  /// Angle between two active pointers.
  final double angle;
}

/// Computed render properties for one layer in current canvas constraints.
final class _LayerRenderData {
  /// Creates render data.
  const _LayerRenderData({
    required this.maxTextWidth,
    required this.contentSize,
    required this.center,
  });

  /// Maximum allowed text width for wrapping.
  final double maxTextWidth;

  /// Measured content size.
  final Size contentSize;

  /// Clamped center position in canvas pixels.
  final Offset center;
}

final class _MemeEditorCanvasState extends State<MemeEditorCanvas> {
  static const double _maxTextWidthFactor = 0.92;
  static const double _minimumEditableTextWidth = 56.0;
  static const double _editableWidthReserve = 20.0;
  static const double _outlineWidthReserve = 8.0;
  static const double _rotationSnapEnterRadians = 6.0 * math.pi / 180.0;
  static const double _rotationSnapReleaseRadians = 8.0 * math.pi / 180.0;
  static const double _trashTargetSize = 62.0;
  static const double _trashTargetBottomInset = 46.0;
  static const Duration _caretTouchModeTimeout = Duration(seconds: 4);
  static const Duration _gestureTapGuardDuration = Duration(milliseconds: 140);
  static const Duration _autoScrollTickInterval = Duration(milliseconds: 16);
  static const double _autoScrollEdgeZoneHeight = 80.0;
  static const double _autoScrollMaxSpeed = 920.0;

  final Map<int, Offset> _activePointerPositions = <int, Offset>{};

  _CanvasTransformSession? _activeTransformSession;
  _CanvasScrollSession? _activeScrollSession;

  bool _isTrashHovered = false;
  bool _isCaretTouchModeEnabled = false;

  Timer? _caretTouchModeTimer;
  Timer? _autoScrollTimer;

  double _autoScrollVelocity = 0.0;

  DateTime? _lastScaleEndAt;
  DateTime? _lastMultiTouchAt;
  DateTime? _lastAutoScrollTickAt;

  Size _latestCanvasSize = Size.zero;
  double _latestViewportHeight = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScrollChanged);
  }

  @override
  void didUpdateWidget(covariant MemeEditorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScrollChanged);
      widget.scrollController.addListener(_handleScrollChanged);
    }

    final _CanvasTransformSession? activeSession = _activeTransformSession;
    if (activeSession != null) {
      final bool stillExists = widget.layers.any(
        (MemeTextLayerEntity layer) => layer.id == activeSession.layerId,
      );
      if (!stillExists) {
        _clearDragDeletionState();
      }
    }

    final bool shouldRequestSelectedLayerFocus =
        widget.isSelectedLayerEditing &&
        (widget.selectedLayerId != oldWidget.selectedLayerId ||
            !oldWidget.isSelectedLayerEditing);
    if (shouldRequestSelectedLayerFocus) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        _requestSelectedLayerFocus(moveCursorToEnd: true);
      });
    }

    if (!widget.isSelectedLayerEditing && _isCaretTouchModeEnabled) {
      _disableCaretTouchMode();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScrollChanged);
    _caretTouchModeTimer?.cancel();
    _stopAutoScroll();
    _activePointerPositions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MemeTemplateListPageItemEntity? currentTemplate = widget.template;

    if (currentTemplate == null) {
      return ColoredBox(
        color: MColors.gray900,
        child: MCenter(
          child: MText.small(
            text: l10n.memeEditorCanvasSelectTemplateHint,
            style: const TextStyle(color: MColors.gray300),
          ),
        ),
      );
    }

    final double selectedAspectRatio = _resolveAspectRatio(
      template: currentTemplate,
    );

    return ColoredBox(
      color: MColors.gray900,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double canvasWidth = constraints.maxWidth;
          final double viewportHeight = constraints.maxHeight;
          if (canvasWidth <= 0.0 || viewportHeight <= 0.0) {
            return const SizedBox.shrink();
          }

          final double canvasHeight = canvasWidth / selectedAspectRatio;
          final Size canvasSize = Size(canvasWidth, canvasHeight);

          _latestCanvasSize = canvasSize;
          _latestViewportHeight = viewportHeight;

          final Map<String, _LayerRenderData> renderDataByLayer =
              _resolveRenderDataByLayer(context, canvasSize);

          return SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: RepaintBoundary(
                key: widget.repaintBoundaryKey,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUpOrCancel,
                  onPointerCancel: _handlePointerUpOrCancel,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (TapUpDetails details) {
                      _handleTapUp(
                        details: details,
                        canvasSize: canvasSize,
                        renderDataByLayer: renderDataByLayer,
                      );
                    },
                    onLongPressStart: (LongPressStartDetails details) {
                      _handleLongPressStart(
                        details: details,
                        renderDataByLayer: renderDataByLayer,
                      );
                    },
                    onScaleStart: (ScaleStartDetails details) {
                      _handleScaleStart(
                        context: context,
                        details: details,
                        canvasSize: canvasSize,
                        renderDataByLayer: renderDataByLayer,
                      );
                    },
                    onScaleUpdate: (ScaleUpdateDetails details) {
                      _handleScaleUpdate(
                        context: context,
                        details: details,
                        canvasSize: canvasSize,
                      );
                    },
                    onScaleEnd: (_) {
                      _handleScaleEnd();
                    },
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: <Widget>[
                        Positioned.fill(
                          child: MImage.url(
                            currentTemplate.signedImageUrl,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                            backgroundColor: MColors.gray900,
                            iconColor: MColors.gray300,
                          ),
                        ),
                        for (final MemeTextLayerEntity layer in widget.layers)
                          _buildLayer(
                            layer: layer,
                            renderData: renderDataByLayer[layer.id],
                          ),
                        if (_activeTransformSession != null)
                          _buildTrashTarget(context, canvasSize),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Reacts to viewport scroll changes while a drag session is active.
  void _handleScrollChanged() {
    final _CanvasTransformSession? session = _activeTransformSession;
    if (session == null || _latestCanvasSize == Size.zero) {
      return;
    }

    _updateTrashHoverState(
      pointerPosition: session.currentFocalPoint,
      pointerCount: session.pointerCount,
      canvasSize: _latestCanvasSize,
      forceRebuild: true,
    );
  }

  /// Builds one rendered layer widget.
  Widget _buildLayer({
    required MemeTextLayerEntity layer,
    required _LayerRenderData? renderData,
  }) {
    final _LayerRenderData? data = renderData;
    if (data == null) {
      return const SizedBox.shrink();
    }

    final bool isSelected = widget.selectedLayerId == layer.id;
    final bool isEditingLayer = widget.isSelectedLayerEditing && isSelected;

    final Widget layerContent = _MemeEditorTextLayer(
      layer: layer,
      isEditable: isEditingLayer,
      isCaretTouchModeEnabled: isEditingLayer && _isCaretTouchModeEnabled,
      textController: widget.selectedTextController,
      textFocusNode: widget.selectedTextFocusNode,
      maxTextWidth: data.maxTextWidth,
      contentWidth: data.contentSize.width,
    );

    return Positioned(
      left: data.center.dx - data.contentSize.width / 2.0,
      top: data.center.dy - data.contentSize.height / 2.0,
      child: Transform.rotate(
        angle: layer.rotationRadians,
        alignment: Alignment.center,
        child: layerContent,
      ),
    );
  }

  /// Handles one completed tap and dispatches layer- or canvas-intent callbacks.
  void _handleTapUp({
    required TapUpDetails details,
    required Size canvasSize,
    required Map<String, _LayerRenderData> renderDataByLayer,
  }) {
    if (_shouldIgnoreTapAfterGesture()) {
      return;
    }

    final Offset tapPoint = details.localPosition;

    if (_isCaretTouchModeEnabled &&
        _isSelectedEditableLayerHit(
          point: tapPoint,
          renderDataByLayer: renderDataByLayer,
        )) {
      _restartCaretTouchModeTimer();
      return;
    }

    final String? hitLayerId = _hitTestTopmostLayerId(
      point: tapPoint,
      renderDataByLayer: renderDataByLayer,
    );

    if (hitLayerId != null) {
      if (_isCaretTouchModeEnabled && hitLayerId != widget.selectedLayerId) {
        _disableCaretTouchMode();
      }
      widget.onTapLayer(hitLayerId);
      return;
    }

    if (_isCaretTouchModeEnabled) {
      _disableCaretTouchMode();
    }

    if (widget.isTextEditingActive) {
      widget.onTapOutsideWhileEditing();
      return;
    }

    final double normalizedX =
        tapPoint.dx.clamp(0.0, canvasSize.width) / canvasSize.width;
    final double normalizedY =
        tapPoint.dy.clamp(0.0, canvasSize.height) / canvasSize.height;
    widget.onTapCanvas(normalizedX, normalizedY);
  }

  /// Returns whether tap callbacks should be suppressed after multi-touch gestures.
  bool _shouldIgnoreTapAfterGesture() {
    final DateTime now = DateTime.now();

    final DateTime? scaleEndAt = _lastScaleEndAt;
    if (scaleEndAt != null &&
        now.difference(scaleEndAt) <= _gestureTapGuardDuration) {
      return true;
    }

    final DateTime? multiTouchAt = _lastMultiTouchAt;
    if (multiTouchAt != null &&
        now.difference(multiTouchAt) <= _gestureTapGuardDuration) {
      return true;
    }

    return false;
  }

  /// Enables caret-touch mode after one long-press on the focused text layer.
  void _handleLongPressStart({
    required LongPressStartDetails details,
    required Map<String, _LayerRenderData> renderDataByLayer,
  }) {
    final bool shouldEnable = _isSelectedEditableLayerHit(
      point: details.localPosition,
      renderDataByLayer: renderDataByLayer,
    );
    if (!shouldEnable) {
      return;
    }

    _enableCaretTouchMode();
    _requestSelectedLayerFocus(moveCursorToEnd: false);
  }

  /// Starts a new transform or viewport-scroll session.
  void _handleScaleStart({
    required BuildContext context,
    required ScaleStartDetails details,
    required Size canvasSize,
    required Map<String, _LayerRenderData> renderDataByLayer,
  }) {
    final Offset focalPoint = details.localFocalPoint;

    if (_isCaretTouchModeEnabled &&
        _isSelectedEditableLayerHit(
          point: focalPoint,
          renderDataByLayer: renderDataByLayer,
        )) {
      _restartCaretTouchModeTimer();
      return;
    }

    if (_isCaretTouchModeEnabled) {
      _disableCaretTouchMode();
    }

    final String? layerId = _hitTestTopmostLayerId(
      point: focalPoint,
      renderDataByLayer: renderDataByLayer,
    );

    if (layerId == null) {
      _clearDragDeletionState();
      _activeScrollSession = _CanvasScrollSession(
        startFocalPoint: focalPoint,
        startScrollOffset: widget.scrollController.offset,
      );
      _lastScaleEndAt = null;
      return;
    }

    final MemeTextLayerEntity? layer = _findLayerById(layerId);
    final _LayerRenderData? renderData = renderDataByLayer[layerId];
    if (layer == null || renderData == null) {
      _clearDragDeletionState();
      return;
    }

    widget.onStartLayerTransform(layerId);

    _activeScrollSession = null;
    _activeTransformSession = _CanvasTransformSession(
      layerId: layerId,
      startFocalPoint: focalPoint,
      currentFocalPoint: focalPoint,
      startCenter: renderData.center,
      currentCenter: renderData.center,
      startFontSize: layer.fontSize,
      currentFontSize: layer.fontSize,
      startRotationRadians: layer.rotationRadians,
      currentRotationRadians: layer.rotationRadians,
      pointerCount: details.pointerCount,
    );

    setState(() {
      _isTrashHovered = false;
    });

    _updateTrashHoverState(
      pointerPosition: focalPoint,
      pointerCount: details.pointerCount,
      canvasSize: canvasSize,
    );

    _updateAutoScrollVelocity(focalPoint: details.localFocalPoint);
    _lastScaleEndAt = null;
  }

  /// Updates current layer transform or background scroll during an active gesture.
  void _handleScaleUpdate({
    required BuildContext context,
    required ScaleUpdateDetails details,
    required Size canvasSize,
  }) {
    final _CanvasTransformSession? session = _activeTransformSession;
    if (session == null) {
      _handleCanvasScrollUpdate(details: details, canvasSize: canvasSize);
      return;
    }

    final MemeTextLayerEntity? layer = _findLayerById(session.layerId);
    if (layer == null) {
      _clearDragDeletionState();
      return;
    }

    if (details.pointerCount != session.pointerCount) {
      _resetSessionForPointerCountTransition(
        session: session,
        details: details,
      );
    }

    final Offset focalPointDelta =
        details.localFocalPoint - session.startFocalPoint;
    session.currentFocalPoint = details.localFocalPoint;
    final Offset rawCenter = session.startCenter + focalPointDelta;
    final bool isTwoFingerGesture = details.pointerCount >= 2;

    double nextFontSize = session.startFontSize;
    double nextRotationRadians = session.startRotationRadians;

    if (isTwoFingerGesture) {
      final _TwoPointerGeometry? geometry = _resolveTwoPointerGeometry();
      if (geometry != null) {
        if (!session.hasTwoFingerBaseline) {
          session.hasTwoFingerBaseline = true;
          session.twoFingerBaselineSpan = geometry.span;
          session.twoFingerBaselineAngle = geometry.angle;
          session.twoFingerBaselineFontSize = session.currentFontSize;
          session.twoFingerBaselineRotationRadians =
              session.currentRotationRadians;
          nextFontSize = session.currentFontSize;
          nextRotationRadians = session.currentRotationRadians;
        } else {
          final double safeBaselineSpan = session.twoFingerBaselineSpan <= 0.0
              ? 1.0
              : session.twoFingerBaselineSpan;
          final double scaleFactor = geometry.span / safeBaselineSpan;
          nextFontSize = (session.twoFingerBaselineFontSize * scaleFactor)
              .clamp(
                MemeEditorValidator.minFontSize,
                MemeEditorValidator.maxFontSize,
              );

          final double rawRotationRadians =
              session.twoFingerBaselineRotationRadians +
              _normalizeRadians(
                geometry.angle - session.twoFingerBaselineAngle,
              );
          nextRotationRadians = _applyRotationSnap(
            rawRotationRadians: rawRotationRadians,
            session: session,
          );
        }
      }
    } else {
      session.hasTwoFingerBaseline = false;
      session.isRotationSnapped = false;
    }

    final bool isEditingLayer =
        widget.isSelectedLayerEditing && widget.selectedLayerId == layer.id;
    final _LayerRenderData nextRenderData = _resolveLayerRenderData(
      context,
      layer: layer,
      canvasSize: canvasSize,
      fontSize: nextFontSize,
      rotationRadians: nextRotationRadians,
      textOverride: _resolveLayerTextForMeasurement(layer),
      isEditable: isEditingLayer,
      centerOverride: rawCenter,
    );

    session.currentCenter = nextRenderData.center;
    session.currentFontSize = nextFontSize;
    session.currentRotationRadians = nextRotationRadians;

    _updateTrashHoverState(
      pointerPosition: session.currentFocalPoint,
      pointerCount: details.pointerCount,
      canvasSize: canvasSize,
    );

    widget.onTransformLayer(
      layer.id,
      nextRenderData.center.dx / canvasSize.width,
      nextRenderData.center.dy / canvasSize.height,
      nextFontSize,
      nextRotationRadians,
    );

    _updateAutoScrollVelocity(focalPoint: details.localFocalPoint);
  }

  /// Updates viewport scroll when dragging on canvas background.
  void _handleCanvasScrollUpdate({
    required ScaleUpdateDetails details,
    required Size canvasSize,
  }) {
    final _CanvasScrollSession? session = _activeScrollSession;
    if (session == null) {
      return;
    }

    final double maxOffset = _maxScrollOffset(canvasSize: canvasSize);
    if (maxOffset <= 0.0) {
      return;
    }

    final double deltaY =
        details.localFocalPoint.dy - session.startFocalPoint.dy;
    final double targetOffset = (session.startScrollOffset - deltaY).clamp(
      0.0,
      maxOffset,
    );

    if ((targetOffset - widget.scrollController.offset).abs() <= 0.1) {
      return;
    }

    widget.scrollController.jumpTo(targetOffset);
  }

  /// Finalizes active gesture and deletes one layer when dropped on trash target.
  void _handleScaleEnd() {
    final _CanvasTransformSession? session = _activeTransformSession;
    final bool shouldDelete = _isTrashHovered;
    final String? deletedLayerId = session?.layerId;

    _activeScrollSession = null;
    _clearDragDeletionState();
    _stopAutoScroll();

    if (shouldDelete && deletedLayerId != null) {
      widget.onDeleteLayer(deletedLayerId);
    }

    _lastScaleEndAt = DateTime.now();
  }

  /// Tracks one new active pointer on the canvas.
  void _handlePointerDown(PointerDownEvent event) {
    _activePointerPositions[event.pointer] = event.localPosition;
    if (_activePointerPositions.length >= 2) {
      _lastMultiTouchAt = DateTime.now();
    }
  }

  /// Updates position for one active pointer.
  void _handlePointerMove(PointerMoveEvent event) {
    _activePointerPositions[event.pointer] = event.localPosition;
  }

  /// Removes one inactive pointer from local pointer tracking.
  void _handlePointerUpOrCancel(PointerEvent event) {
    _activePointerPositions.remove(event.pointer);
  }

  /// Resolves one two-pointer geometry snapshot from active pointer map.
  _TwoPointerGeometry? _resolveTwoPointerGeometry() {
    if (_activePointerPositions.length < 2) {
      return null;
    }

    final List<MapEntry<int, Offset>> entries =
        _activePointerPositions.entries.toList(growable: false)
          ..sort((MapEntry<int, Offset> a, MapEntry<int, Offset> b) {
            return a.key.compareTo(b.key);
          });

    final Offset firstPointer = entries[0].value;
    final Offset secondPointer = entries[1].value;
    final Offset delta = secondPointer - firstPointer;
    final double span = delta.distance;
    if (span <= 0.0) {
      return null;
    }

    return _TwoPointerGeometry(
      span: span,
      angle: math.atan2(delta.dy, delta.dx),
    );
  }

  /// Resets transform baseline when pointer count changes mid-gesture.
  void _resetSessionForPointerCountTransition({
    required _CanvasTransformSession session,
    required ScaleUpdateDetails details,
  }) {
    session.pointerCount = details.pointerCount;
    session.startFocalPoint = details.localFocalPoint;
    session.currentFocalPoint = details.localFocalPoint;
    session.startCenter = session.currentCenter;
    session.startFontSize = session.currentFontSize;
    session.startRotationRadians = session.currentRotationRadians;
    session.hasTwoFingerBaseline = false;
    if (details.pointerCount < 2) {
      session.isRotationSnapped = false;
    }
  }

  /// Updates hover state for the trash target based on pointer hit-testing.
  void _updateTrashHoverState({
    required Offset pointerPosition,
    required int pointerCount,
    required Size canvasSize,
    bool forceRebuild = false,
  }) {
    final Offset trashCenter = _resolveTrashCenter(canvasSize);
    final bool isHovered =
        pointerCount == 1 &&
        (pointerPosition - trashCenter).distance <= _trashTargetSize / 2.0;

    if (isHovered == _isTrashHovered && !forceRebuild) {
      return;
    }

    setState(() {
      _isTrashHovered = isHovered;
    });
  }

  /// Starts or updates edge-zone auto-scroll while dragging one text layer.
  void _updateAutoScrollVelocity({required Offset focalPoint}) {
    final _CanvasTransformSession? session = _activeTransformSession;
    if (session == null || _latestCanvasSize == Size.zero) {
      _stopAutoScroll();
      return;
    }

    final double maxOffset = _maxScrollOffset(canvasSize: _latestCanvasSize);
    if (maxOffset <= 0.0) {
      _stopAutoScroll();
      return;
    }

    final double viewportY = focalPoint.dy - widget.scrollController.offset;
    final double velocity = _resolveEdgeAutoScrollVelocity(viewportY);

    if (velocity.abs() < 0.1) {
      _stopAutoScroll();
      return;
    }

    _autoScrollVelocity = velocity;
    _lastAutoScrollTickAt ??= DateTime.now();

    _autoScrollTimer ??= Timer.periodic(
      _autoScrollTickInterval,
      _handleAutoScrollTick,
    );
  }

  /// Resolves one auto-scroll speed from [viewportY] in current viewport space.
  double _resolveEdgeAutoScrollVelocity(double viewportY) {
    if (_latestViewportHeight <= 0.0) {
      return 0.0;
    }

    if (viewportY < _autoScrollEdgeZoneHeight) {
      final double ratio = (1.0 - (viewportY / _autoScrollEdgeZoneHeight))
          .clamp(0.0, 1.0);
      return -_autoScrollMaxSpeed * ratio;
    }

    final double lowerEdge = _latestViewportHeight - _autoScrollEdgeZoneHeight;
    if (viewportY > lowerEdge) {
      final double ratio = ((viewportY - lowerEdge) / _autoScrollEdgeZoneHeight)
          .clamp(0.0, 1.0);
      return _autoScrollMaxSpeed * ratio;
    }

    return 0.0;
  }

  /// Applies one edge auto-scroll tick and keeps dragged text under the finger.
  void _handleAutoScrollTick(Timer _) {
    final _CanvasTransformSession? session = _activeTransformSession;
    if (session == null || _autoScrollVelocity.abs() < 0.1) {
      _stopAutoScroll();
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime? lastTick = _lastAutoScrollTickAt;
    _lastAutoScrollTickAt = now;
    if (lastTick == null) {
      return;
    }

    final double deltaSeconds =
        now.difference(lastTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    if (deltaSeconds <= 0.0) {
      return;
    }

    final double maxOffset = _maxScrollOffset(canvasSize: _latestCanvasSize);
    if (maxOffset <= 0.0) {
      _stopAutoScroll();
      return;
    }

    final double previousOffset = widget.scrollController.offset;
    final double nextOffset =
        (previousOffset + (_autoScrollVelocity * deltaSeconds)).clamp(
          0.0,
          maxOffset,
        );
    final double actualScrollDelta = nextOffset - previousOffset;
    if (actualScrollDelta.abs() < 0.01) {
      return;
    }

    widget.scrollController.jumpTo(nextOffset);

    final MemeTextLayerEntity? layer = _findLayerById(session.layerId);
    if (layer == null || _latestCanvasSize == Size.zero) {
      _clearDragDeletionState();
      _stopAutoScroll();
      return;
    }

    final Offset scrollDelta = Offset(0.0, actualScrollDelta);
    session.startFocalPoint += scrollDelta;
    session.currentFocalPoint += scrollDelta;
    session.startCenter += scrollDelta;
    session.currentCenter += scrollDelta;

    final bool isEditingLayer =
        widget.isSelectedLayerEditing && widget.selectedLayerId == layer.id;
    final _LayerRenderData nextRenderData = _resolveLayerRenderData(
      context,
      layer: layer,
      canvasSize: _latestCanvasSize,
      fontSize: session.currentFontSize,
      rotationRadians: session.currentRotationRadians,
      textOverride: _resolveLayerTextForMeasurement(layer),
      isEditable: isEditingLayer,
      centerOverride: session.currentCenter,
    );

    session.currentCenter = nextRenderData.center;
    session.startCenter = nextRenderData.center;

    _updateTrashHoverState(
      pointerPosition: session.currentFocalPoint,
      pointerCount: session.pointerCount,
      canvasSize: _latestCanvasSize,
      forceRebuild: true,
    );

    widget.onTransformLayer(
      layer.id,
      nextRenderData.center.dx / _latestCanvasSize.width,
      nextRenderData.center.dy / _latestCanvasSize.height,
      session.currentFontSize,
      session.currentRotationRadians,
    );
  }

  /// Stops edge auto-scroll state and ticker.
  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollVelocity = 0.0;
    _lastAutoScrollTickAt = null;
  }

  /// Returns the current maximum vertical scroll offset for [canvasSize].
  double _maxScrollOffset({required Size canvasSize}) {
    if (_latestViewportHeight <= 0.0) {
      return 0.0;
    }

    return math.max(0.0, canvasSize.height - _latestViewportHeight);
  }

  /// Clears active drag-to-delete UI state.
  void _clearDragDeletionState() {
    if (_activeTransformSession == null && !_isTrashHovered) {
      return;
    }

    setState(() {
      _activeTransformSession = null;
      _isTrashHovered = false;
    });
  }

  /// Builds render snapshots for all visible layers.
  Map<String, _LayerRenderData> _resolveRenderDataByLayer(
    BuildContext context,
    Size canvasSize,
  ) {
    final Map<String, _LayerRenderData> result = <String, _LayerRenderData>{};

    for (final MemeTextLayerEntity layer in widget.layers) {
      final bool isEditingLayer =
          widget.isSelectedLayerEditing && widget.selectedLayerId == layer.id;

      result[layer.id] = _resolveLayerRenderData(
        context,
        layer: layer,
        canvasSize: canvasSize,
        fontSize: layer.fontSize,
        rotationRadians: layer.rotationRadians,
        textOverride: _resolveLayerTextForMeasurement(layer),
        isEditable: isEditingLayer,
      );
    }

    return result;
  }

  /// Returns text used to measure one layer in current UI state.
  String _resolveLayerTextForMeasurement(MemeTextLayerEntity layer) {
    final bool isEditingLayer =
        widget.isSelectedLayerEditing && widget.selectedLayerId == layer.id;
    if (!isEditingLayer) {
      return layer.text;
    }

    return widget.selectedTextController.text;
  }

  /// Finds topmost layer that contains [point].
  String? _hitTestTopmostLayerId({
    required Offset point,
    required Map<String, _LayerRenderData> renderDataByLayer,
  }) {
    for (final MemeTextLayerEntity layer in widget.layers.reversed) {
      final _LayerRenderData? renderData = renderDataByLayer[layer.id];
      if (renderData == null) {
        continue;
      }

      final bool contains = _containsPointWithinLayer(
        point: point,
        layer: layer,
        renderData: renderData,
      );
      if (contains) {
        return layer.id;
      }
    }

    return null;
  }

  /// Returns whether [point] is inside currently selected editable layer.
  bool _isSelectedEditableLayerHit({
    required Offset point,
    required Map<String, _LayerRenderData> renderDataByLayer,
  }) {
    if (!widget.isTextEditingActive) {
      return false;
    }

    final String? selectedLayerId = widget.selectedLayerId;
    if (selectedLayerId == null) {
      return false;
    }

    final MemeTextLayerEntity? selectedLayer = _findLayerById(selectedLayerId);
    final _LayerRenderData? renderData = renderDataByLayer[selectedLayerId];
    if (selectedLayer == null || renderData == null) {
      return false;
    }

    return _containsPointWithinLayer(
      point: point,
      layer: selectedLayer,
      renderData: renderData,
    );
  }

  /// Returns whether [point] lies inside rotated bounds of [layer].
  bool _containsPointWithinLayer({
    required Offset point,
    required MemeTextLayerEntity layer,
    required _LayerRenderData renderData,
  }) {
    final Offset centeredPoint = point - renderData.center;
    final double sinValue = math.sin(-layer.rotationRadians);
    final double cosValue = math.cos(-layer.rotationRadians);

    final double localX =
        centeredPoint.dx * cosValue - centeredPoint.dy * sinValue;
    final double localY =
        centeredPoint.dx * sinValue + centeredPoint.dy * cosValue;

    final double halfWidth = renderData.contentSize.width / 2.0;
    final double halfHeight = renderData.contentSize.height / 2.0;

    return localX >= -halfWidth &&
        localX <= halfWidth &&
        localY >= -halfHeight &&
        localY <= halfHeight;
  }

  /// Finds one layer by [layerId].
  MemeTextLayerEntity? _findLayerById(String layerId) {
    for (final MemeTextLayerEntity layer in widget.layers) {
      if (layer.id == layerId) {
        return layer;
      }
    }

    return null;
  }

  /// Enables caret-touch mode for the focused selected layer.
  void _enableCaretTouchMode() {
    if (!_isCaretTouchModeEnabled) {
      setState(() {
        _isCaretTouchModeEnabled = true;
      });
    }
    _restartCaretTouchModeTimer();
  }

  /// Disables caret-touch mode and cancels timeout timer.
  void _disableCaretTouchMode() {
    _caretTouchModeTimer?.cancel();
    _caretTouchModeTimer = null;

    if (!_isCaretTouchModeEnabled) {
      return;
    }

    setState(() {
      _isCaretTouchModeEnabled = false;
    });
  }

  /// Restarts inactivity timer used by caret-touch mode.
  void _restartCaretTouchModeTimer() {
    _caretTouchModeTimer?.cancel();
    _caretTouchModeTimer = Timer(_caretTouchModeTimeout, () {
      if (!mounted) {
        return;
      }
      _disableCaretTouchMode();
    });
  }

  /// Builds the floating trash target shown while dragging one layer.
  Widget _buildTrashTarget(BuildContext context, Size canvasSize) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Offset trashCenter = _resolveTrashCenter(canvasSize);
    final Color backgroundColor = _isTrashHovered
        ? MColors.red600.withValues(alpha: 0.80)
        : MColors.gray900.withValues(alpha: 0.55);
    final Color borderColor = _isTrashHovered
        ? MColors.red300
        : MColors.gray300;

    return Positioned(
      left: trashCenter.dx - _trashTargetSize / 2.0,
      top: trashCenter.dy - _trashTargetSize / 2.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _isTrashHovered ? 1.12 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: _trashTargetSize,
          height: _trashTargetSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Semantics(
            label: l10n.memeEditorDeleteTargetSemanticsLabel,
            child: Icon(
              LucideIcons.trash_2,
              size: 26.0,
              color: _isTrashHovered ? MColors.white : MColors.gray200,
            ),
          ),
        ),
      ),
    );
  }

  /// Resolves trash-target center for the current canvas/viewport relationship.
  Offset _resolveTrashCenter(Size canvasSize) {
    final bool isFullyVisible =
        canvasSize.height <= _latestViewportHeight + 0.5;
    final double centerY = isFullyVisible
        ? canvasSize.height - _trashTargetBottomInset
        : (widget.scrollController.offset + _latestViewportHeight) -
              _trashTargetBottomInset;

    final double clampedY = centerY.clamp(
      _trashTargetSize / 2.0,
      canvasSize.height - _trashTargetSize / 2.0,
    );

    return Offset(canvasSize.width / 2.0, clampedY);
  }

  /// Requests focus for selected inline editor once it is mounted.
  void _requestSelectedLayerFocus({required bool moveCursorToEnd}) {
    if (!mounted || !widget.isSelectedLayerEditing) {
      return;
    }

    final FocusNode focusNode = widget.selectedTextFocusNode;
    final TextEditingController controller = widget.selectedTextController;

    if (moveCursorToEnd) {
      final int textLength = controller.text.length;
      controller.selection = TextSelection.collapsed(offset: textLength);
    }

    if (focusNode.hasFocus) {
      return;
    }

    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Applies upright snapping around vertical alignment to [rawRotationRadians].
  double _applyRotationSnap({
    required double rawRotationRadians,
    required _CanvasTransformSession session,
  }) {
    final double normalized = _normalizeRadians(rawRotationRadians);
    final double distanceToUpright = normalized.abs();
    final double uprightRotation = rawRotationRadians - normalized;

    if (session.isRotationSnapped) {
      if (distanceToUpright > _rotationSnapReleaseRadians) {
        session.isRotationSnapped = false;
        return rawRotationRadians;
      }
      return uprightRotation;
    }

    if (distanceToUpright <= _rotationSnapEnterRadians) {
      session.isRotationSnapped = true;
      return uprightRotation;
    }

    return rawRotationRadians;
  }

  /// Normalizes [rotationRadians] to the `[-pi, pi]` interval.
  double _normalizeRadians(double rotationRadians) {
    final double twoPi = 2.0 * math.pi;
    double normalized = rotationRadians % twoPi;
    if (normalized > math.pi) {
      normalized -= twoPi;
    } else if (normalized < -math.pi) {
      normalized += twoPi;
    }
    return normalized;
  }

  /// Resolves one render-data snapshot for [layer].
  _LayerRenderData _resolveLayerRenderData(
    BuildContext context, {
    required MemeTextLayerEntity layer,
    required Size canvasSize,
    required double fontSize,
    required double rotationRadians,
    required String textOverride,
    required bool isEditable,
    Offset? centerOverride,
  }) {
    final double maxTextWidth = canvasSize.width * _maxTextWidthFactor;
    final Size contentSize = _measureLayerContentSize(
      context,
      text: textOverride,
      fontSize: fontSize,
      maxTextWidth: maxTextWidth,
      isEditable: isEditable,
      layer: layer,
    );

    final Offset rawCenter =
        centerOverride ??
        Offset(
          layer.positionX * canvasSize.width,
          layer.positionY * canvasSize.height,
        );

    final Offset clampedCenter = _clampLayerCenter(
      rawCenter: rawCenter,
      contentSize: contentSize,
      rotationRadians: rotationRadians,
      canvasSize: canvasSize,
    );

    return _LayerRenderData(
      maxTextWidth: maxTextWidth,
      contentSize: contentSize,
      center: clampedCenter,
    );
  }

  /// Measures rendered layer content size in pixels.
  Size _measureLayerContentSize(
    BuildContext context, {
    required String text,
    required double fontSize,
    required double maxTextWidth,
    required bool isEditable,
    required MemeTextLayerEntity layer,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text.isEmpty ? ' ' : text,
        style: _layerFillTextStyle(layer, fontSize),
      ),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxTextWidth);

    double resolvedWidth = painter.width;
    if (isEditable) {
      resolvedWidth += _editableWidthReserve;
      resolvedWidth = math.max(resolvedWidth, _minimumEditableTextWidth);
    }
    if (layer.hasBackground) {
      resolvedWidth += _outlineWidthReserve;
    }

    return Size(resolvedWidth, painter.height);
  }

  /// Clamps center so rotated layer bounds stay fully inside the image.
  Offset _clampLayerCenter({
    required Offset rawCenter,
    required Size contentSize,
    required double rotationRadians,
    required Size canvasSize,
  }) {
    final double halfWidth = contentSize.width / 2.0;
    final double halfHeight = contentSize.height / 2.0;

    final double absCos = math.cos(rotationRadians).abs();
    final double absSin = math.sin(rotationRadians).abs();

    final double rotatedHalfWidth = halfWidth * absCos + halfHeight * absSin;
    final double rotatedHalfHeight = halfWidth * absSin + halfHeight * absCos;

    final double minX = rotatedHalfWidth;
    final double maxX = canvasSize.width - rotatedHalfWidth;
    final double minY = rotatedHalfHeight;
    final double maxY = canvasSize.height - rotatedHalfHeight;

    final double centerX = minX > maxX
        ? canvasSize.width / 2.0
        : rawCenter.dx.clamp(minX, maxX);
    final double centerY = minY > maxY
        ? canvasSize.height / 2.0
        : rawCenter.dy.clamp(minY, maxY);

    return Offset(centerX, centerY);
  }

  /// Resolves currently active background aspect ratio.
  double _resolveAspectRatio({
    required MemeTemplateListPageItemEntity? template,
  }) {
    final MemeTemplateListPageItemEntity? currentTemplate = template;
    if (currentTemplate != null) {
      final double ratio = currentTemplate.aspectRatio;
      return ratio > 0.0 ? ratio : 1.0;
    }

    return 1.0;
  }
}

/// One rendered text-layer widget on the meme canvas.
final class _MemeEditorTextLayer extends StatelessWidget {
  /// Creates one rendered text-layer widget.
  const _MemeEditorTextLayer({
    required this.layer,
    required this.isEditable,
    required this.isCaretTouchModeEnabled,
    required this.textController,
    required this.textFocusNode,
    required this.maxTextWidth,
    required this.contentWidth,
  });

  /// Text-layer entity rendered by this widget.
  final MemeTextLayerEntity layer;

  /// Whether this layer is currently inline-editable.
  final bool isEditable;

  /// Whether touch interactions on inline text should affect caret/selection.
  final bool isCaretTouchModeEnabled;

  /// Controller bound to selected-layer text.
  final TextEditingController textController;

  /// Focus node bound to selected-layer text.
  final FocusNode textFocusNode;

  /// Maximum text width used for line wrapping.
  final double maxTextWidth;

  /// Resolved current layer width.
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTextWidth),
      child: isEditable
          ? _EditableLayerText(
              layer: layer,
              textController: textController,
              textFocusNode: textFocusNode,
              isCaretTouchModeEnabled: isCaretTouchModeEnabled,
              contentWidth: contentWidth,
            )
          : _StaticLayerText(layer: layer),
    );
  }
}

/// Static rendered text layer.
final class _StaticLayerText extends StatelessWidget {
  /// Creates static layer text.
  const _StaticLayerText({required this.layer});

  /// Layer entity used for rendering.
  final MemeTextLayerEntity layer;

  @override
  Widget build(BuildContext context) {
    final String text = layer.text.isEmpty ? ' ' : layer.text;
    if (!layer.hasBackground) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: _layerFillTextStyle(layer, layer.fontSize),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Text(
          text,
          textAlign: TextAlign.center,
          style: _layerStrokeTextStyle(layer, layer.fontSize),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: _layerFillTextStyle(layer, layer.fontSize),
        ),
      ],
    );
  }
}

/// Editable text layer rendered inline on canvas.
final class _EditableLayerText extends StatelessWidget {
  /// Creates editable inline text.
  const _EditableLayerText({
    required this.layer,
    required this.textController,
    required this.textFocusNode,
    required this.isCaretTouchModeEnabled,
    required this.contentWidth,
  });

  /// Layer entity used for rendering.
  final MemeTextLayerEntity layer;

  /// Controller bound to selected-layer text.
  final TextEditingController textController;

  /// Focus node bound to selected-layer text.
  final FocusNode textFocusNode;

  /// Whether touch interactions should be forwarded to the [TextField].
  final bool isCaretTouchModeEnabled;

  /// Resolved current width of this editable text layer.
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final TextStyle fillStyle = _layerFillTextStyle(layer, layer.fontSize);
    final TextStyle transparentInputStyle = fillStyle.copyWith(
      color: Colors.transparent,
    );
    final StrutStyle strutStyle = StrutStyle.fromTextStyle(
      fillStyle,
      forceStrutHeight: true,
    );

    return SizedBox(
      width: contentWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          IgnorePointer(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: textController,
              builder:
                  (
                    BuildContext context,
                    TextEditingValue value,
                    Widget? child,
                  ) {
                    final String text = value.text.isEmpty ? ' ' : value.text;
                    if (!layer.hasBackground) {
                      return SizedBox(
                        width: double.infinity,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          textWidthBasis: TextWidthBasis.parent,
                          strutStyle: strutStyle,
                          style: fillStyle,
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              textWidthBasis: TextWidthBasis.parent,
                              strutStyle: strutStyle,
                              style: _layerStrokeTextStyle(
                                layer,
                                layer.fontSize,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              textWidthBasis: TextWidthBasis.parent,
                              strutStyle: strutStyle,
                              style: fillStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
          ),
          IgnorePointer(
            ignoring: !isCaretTouchModeEnabled,
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                key: const ValueKey<String>('meme-editor-layer-text-field'),
                controller: textController,
                focusNode: textFocusNode,
                autofocus: false,
                keyboardAppearance: Brightness.dark,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: null,
                cursorColor: Color(layer.textColorValue),
                enableInteractiveSelection: isCaretTouchModeEnabled,
                onTapOutside: (PointerDownEvent _) {
                  // Keep focus while interacting with editor controls.
                },
                strutStyle: strutStyle,
                textAlignVertical: TextAlignVertical.top,
                scrollPadding: EdgeInsets.zero,
                style: transparentInputStyle,
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns the text-fill style used for meme text overlays.
TextStyle _layerFillTextStyle(MemeTextLayerEntity layer, double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    color: Color(layer.textColorValue),
    fontWeight: FontWeight.w800,
  );
}

/// Returns the text-stroke style used for optional outline rendering.
TextStyle _layerStrokeTextStyle(MemeTextLayerEntity layer, double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = Color(layer.backgroundColorValue),
  );
}
