import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MImage extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final bool isLoading;
  final bool hasError;
  final int retries;
  final IconData errorIcon;
  final IconData placeholderIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final FilterQuality filterQuality;

  const MImage.url(
    this.url, {
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.retries = 3,
    this.errorIcon = LucideIcons.image_off,
    this.placeholderIcon = LucideIcons.image,
    this.backgroundColor,
    this.iconColor,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
  }) : bytes = null,
       assert(retries >= 0, 'retries must be >= 0');

  const MImage.bytes(
    this.bytes, {
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.retries = 3,
    this.errorIcon = LucideIcons.image_off,
    this.placeholderIcon = LucideIcons.image,
    this.backgroundColor,
    this.iconColor,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
  }) : url = null,
       assert(retries >= 0, 'retries must be >= 0');

  @override
  State<MImage> createState() => _MImageState();
}

String? _trimmedUrl(String? rawUrl) {
  final String? trimmed = rawUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

enum _MImageStatus { idle, loading, ready, error }

class _MImageState extends State<MImage> with SingleTickerProviderStateMixin {
  static const ValueKey<String> _skeletonKey = ValueKey<String>(
    'm_image_skeleton',
  );

  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  _MImageStatus _status = _MImageStatus.idle;
  ImageProvider<Object>? _provider;
  int _loadToken = 0;

  String? get _sourceUrl => _trimmedUrl(widget.url);
  Uint8List? get _sourceBytes => widget.bytes;
  bool get _hasUrlSource => _sourceUrl != null;
  bool get _hasBytesSource => _sourceBytes != null && _sourceBytes!.isNotEmpty;
  bool get _hasSource => _hasUrlSource || _hasBytesSource;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    if (widget.hasError) {
      _status = _MImageStatus.error;
      return;
    }

    if (widget.isLoading) {
      return;
    }

    _kickoffLoadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool sourceChanged =
        _trimmedUrl(oldWidget.url) != _sourceUrl ||
        !listEquals(oldWidget.bytes, widget.bytes);
    if (sourceChanged) {
      _resetState();
    }

    if (widget.hasError) {
      _setError();
      return;
    }

    if (widget.isLoading) {
      return;
    }

    if (sourceChanged) {
      _kickoffLoadIfNeeded();
      return;
    }

    final bool stoppedForcedLoading = oldWidget.isLoading && !widget.isLoading;
    if (stoppedForcedLoading) {
      _kickoffLoadIfNeeded();
      return;
    }

    if (_provider == null && _status != _MImageStatus.loading && _hasSource) {
      _kickoffLoadIfNeeded();
    }
  }

  void _resetState() {
    _loadToken++;
    _fadeController.value = 0;

    setState(() {
      _provider = null;
      _status = _MImageStatus.idle;
    });
  }

  void _setError() {
    _loadToken++;
    _fadeController.value = 0;

    setState(() {
      _provider = null;
      _status = _MImageStatus.error;
    });
  }

  void _kickoffLoadIfNeeded() {
    if (!mounted) {
      return;
    }

    if (widget.isLoading || widget.hasError) {
      return;
    }

    if (!_hasSource) {
      setState(() {
        _provider = null;
        _status = _MImageStatus.idle;
      });
      return;
    }

    unawaited(_load());
  }

  Future<void> _load() async {
    final int token = ++_loadToken;

    setState(() {
      _status = _MImageStatus.loading;
    });
    _fadeController.value = 0;

    try {
      final ImageProvider<Object> provider = await _resolveProvider();
      if (!mounted || token != _loadToken) {
        return;
      }

      await precacheImage(provider, context);

      if (!mounted || token != _loadToken) {
        return;
      }

      if (widget.isLoading || widget.hasError) {
        return;
      }

      setState(() {
        _provider = provider;
        _status = _MImageStatus.ready;
      });
      _fadeController.forward(from: 0);
    } catch (_) {
      if (!mounted || token != _loadToken) {
        return;
      }

      if (widget.isLoading || widget.hasError) {
        return;
      }

      setState(() {
        _provider = null;
        _status = _MImageStatus.error;
      });
    }
  }

  Future<ImageProvider<Object>> _resolveProvider() async {
    if (_hasBytesSource) {
      return MemoryImage(_sourceBytes!);
    }

    final String? url = _sourceUrl;
    if (url == null) {
      throw StateError('No image source provided.');
    }

    return _resolveNetworkProviderWithRetries(url);
  }

  Future<ImageProvider<Object>> _resolveNetworkProviderWithRetries(
    String url,
  ) async {
    Object? lastError;

    for (int attempt = 0; attempt <= widget.retries; attempt++) {
      try {
        final NetworkImage provider = NetworkImage(url);
        final ImageStream stream = provider.resolve(const ImageConfiguration());
        final Completer<void> completer = Completer<void>();

        late final ImageStreamListener listener;
        listener = ImageStreamListener(
          (ImageInfo _, bool _) {
            stream.removeListener(listener);
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (Object error, StackTrace? _) {
            stream.removeListener(listener);
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        );

        stream.addListener(listener);
        await completer.future;

        return provider;
      } catch (error) {
        lastError = error;
        if (attempt >= widget.retries) {
          break;
        }

        final int delayMs = 200 * (attempt + 1) * (attempt + 1);
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }

    throw lastError ?? StateError('Unknown network image error.');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius clipRadius = widget.borderRadius ?? BorderRadius.zero;

    Widget base = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? MColors.gray800,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(borderRadius: clipRadius, child: _buildContent()),
    );

    if (widget.aspectRatio != null) {
      base = AspectRatio(aspectRatio: widget.aspectRatio!, child: base);
    }

    if (widget.width != null || widget.height != null) {
      base = SizedBox(width: widget.width, height: widget.height, child: base);
    }

    return base;
  }

  Widget _buildContent() {
    if (widget.hasError) {
      return _iconState(widget.errorIcon);
    }

    if (widget.isLoading) {
      return _skeletonBox();
    }

    if (!_hasSource) {
      return _iconState(widget.placeholderIcon);
    }

    return switch (_status) {
      _MImageStatus.error => _iconState(widget.errorIcon),
      _MImageStatus.ready => _fadingImage(),
      _MImageStatus.loading => _skeletonBox(),
      _MImageStatus.idle => _skeletonBox(),
    };
  }

  Widget _fadingImage() {
    final ImageProvider<Object>? provider = _provider;
    if (provider == null) {
      return _skeletonBox();
    }

    return FadeTransition(opacity: _fade, child: _image(provider));
  }

  Widget _image(ImageProvider<Object> provider, {BoxFit? fit}) {
    return Image(
      image: provider,
      fit: fit ?? widget.fit,
      filterQuality: widget.filterQuality,
      gaplessPlayback: true,
    );
  }

  Widget _skeletonBox() {
    return Skeletonizer(
      enabled: true,
      child: Skeleton.leaf(
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.black),
          child: SizedBox.expand(key: _skeletonKey),
        ),
      ),
    );
  }

  Widget _iconState(IconData icon) {
    final Color color = widget.iconColor ?? MColors.gray400;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double shortestSide = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final double iconSize = shortestSide.isFinite
            ? shortestSide * 0.5
            : 16.0;

        return Center(
          child: Icon(icon, color: color, size: iconSize),
        );
      },
    );
  }
}
