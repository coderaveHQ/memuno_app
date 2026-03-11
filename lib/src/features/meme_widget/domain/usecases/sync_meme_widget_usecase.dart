import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:memuno_app/src/features/meme_widget/data/services/meme_widget_image_cache.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/load_latest_meme_widget_items_usecase.dart';

/// Usecase for rebuilding and persisting the widget snapshot.
final class SyncMemeWidgetUsecase {
  /// Creates the usecase.
  const SyncMemeWidgetUsecase({
    required LoadLatestMemeWidgetItemsUsecase loadLatestItemsUsecase,
    required MemeWidgetLocalRepository localRepository,
  }) : _loadLatestItemsUsecase = loadLatestItemsUsecase,
       _localRepository = localRepository;

  final LoadLatestMemeWidgetItemsUsecase _loadLatestItemsUsecase;
  final MemeWidgetLocalRepository _localRepository;

  /// Maximum number of widget memes.
  static const int itemLimit = 5;

  /// Default background color (`MColors.gray900`).
  static const String _defaultBackgroundHex = '#191919';

  /// Default foreground color (`MColors.gray100`).
  static const String _defaultForegroundHex = '#FBFBFB';

  /// Synchronizes snapshot data for [texts] and updates native widgets.
  Future<void> call({required MemeWidgetTextsEntity texts}) async {
    final MemeWidgetSnapshotEntity? previousSnapshot = await _localRepository
        .loadSnapshot();

    final List<MemeWidgetItemEntity> items = await _loadLatestItemsUsecase(
      limit: itemLimit,
    );

    final List<MemeWidgetItemEntity> enrichedItems = await Future.wait(
      items.map(_prepareItem),
    );

    final MemeWidgetSnapshotStatus status = enrichedItems.isEmpty
        ? MemeWidgetSnapshotStatus.empty
        : MemeWidgetSnapshotStatus.ready;

    final int selectedIndex = _resolveSelectedIndex(
      previousSnapshot: previousSnapshot,
      nextItems: enrichedItems,
    );

    final MemeWidgetSnapshotEntity snapshot = MemeWidgetSnapshotEntity(
      status: status,
      items: List<MemeWidgetItemEntity>.unmodifiable(enrichedItems),
      selectedIndex: selectedIndex,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      pendingLaughMemeId: null,
      emptyText: texts.emptyText,
      signedOutText: texts.signedOutText,
      laughActionText: texts.laughActionText,
      unlaughActionText: texts.unlaughActionText,
      ownerActionText: texts.ownerActionText,
    );

    await _localRepository.saveSnapshot(snapshot);
    await _localRepository.refreshNativeWidget();
  }

  Future<MemeWidgetItemEntity> _prepareItem(MemeWidgetItemEntity item) async {
    final Uint8List? bytes = await MemeWidgetImageCache.downloadImageBytes(
      item.imageUrlFull,
    );
    if (bytes == null || bytes.isEmpty) {
      return item.copyWith(
        backgroundHex: _defaultBackgroundHex,
        foregroundHex: _defaultForegroundHex,
      );
    }

    final ({String backgroundHex, String foregroundHex}) colors =
        _resolveColors(bytes);

    final String? cachedPath = await MemeWidgetImageCache.cacheImageBytes(
      memeId: item.memeId,
      bytes: bytes,
    );

    return item.copyWith(
      backgroundHex: colors.backgroundHex,
      foregroundHex: colors.foregroundHex,
      androidCachedImagePath: cachedPath,
    );
  }

  ({String backgroundHex, String foregroundHex}) _resolveColors(
    Uint8List bytes,
  ) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return (
        backgroundHex: _defaultBackgroundHex,
        foregroundHex: _defaultForegroundHex,
      );
    }

    final img.Image sampled = img.copyResize(
      decoded,
      width: decoded.width > 32 ? 32 : decoded.width,
      height: decoded.height > 32 ? 32 : decoded.height,
      interpolation: img.Interpolation.average,
    );

    int red = 0;
    int green = 0;
    int blue = 0;
    int count = 0;

    for (int y = 0; y < sampled.height; y += 1) {
      for (int x = 0; x < sampled.width; x += 1) {
        final img.Pixel pixel = sampled.getPixel(x, y);
        final int alpha = pixel.a.toInt();
        if (alpha == 0) {
          continue;
        }

        red += pixel.r.toInt();
        green += pixel.g.toInt();
        blue += pixel.b.toInt();
        count += 1;
      }
    }

    if (count == 0) {
      return (
        backgroundHex: _defaultBackgroundHex,
        foregroundHex: _defaultForegroundHex,
      );
    }

    final int r = (red / count).round().clamp(0, 255).toInt();
    final int g = (green / count).round().clamp(0, 255).toInt();
    final int b = (blue / count).round().clamp(0, 255).toInt();

    final double luminance = ((r * 299) + (g * 587) + (b * 114)) / 1000;
    final String foregroundHex = luminance >= 140
        ? _hex(0x19, 0x19, 0x19)
        : _hex(0xFB, 0xFB, 0xFB);

    return (backgroundHex: _hex(r, g, b), foregroundHex: foregroundHex);
  }

  int _resolveSelectedIndex({
    required MemeWidgetSnapshotEntity? previousSnapshot,
    required List<MemeWidgetItemEntity> nextItems,
  }) {
    if (nextItems.isEmpty) {
      return 0;
    }

    if (previousSnapshot == null || previousSnapshot.items.isEmpty) {
      return 0;
    }

    final Set<String> previousIds = previousSnapshot.items
        .map((MemeWidgetItemEntity item) => item.memeId)
        .toSet();

    final bool hasInsertedNewMeme = nextItems.any(
      (MemeWidgetItemEntity item) => !previousIds.contains(item.memeId),
    );
    if (hasInsertedNewMeme) {
      return 0;
    }

    final int currentIndex = previousSnapshot.safeSelectedIndex;
    final String selectedMemeId = previousSnapshot.items[currentIndex].memeId;
    final int newIndex = nextItems.indexWhere(
      (MemeWidgetItemEntity item) => item.memeId == selectedMemeId,
    );

    if (newIndex >= 0) {
      return newIndex;
    }

    return 0;
  }

  String _hex(int r, int g, int b) {
    String toHex(int value) => value.toRadixString(16).padLeft(2, '0');
    return '#${toHex(r)}${toHex(g)}${toHex(b)}'.toUpperCase();
  }
}
