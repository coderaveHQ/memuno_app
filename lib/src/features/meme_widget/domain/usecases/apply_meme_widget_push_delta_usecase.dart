import 'package:memuno_app/src/features/meme_widget/data/services/meme_widget_image_cache.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_push_delta_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';

/// Result of attempting a local widget update from push delta payload.
final class ApplyMemeWidgetPushDeltaResult {
  /// Creates one result model.
  const ApplyMemeWidgetPushDeltaResult({
    required this.didApply,
    required this.requiresSyncFallback,
  });

  /// Whether a snapshot update was written locally.
  final bool didApply;

  /// Whether caller should execute full sync fallback.
  final bool requiresSyncFallback;
}

/// Applies push-enriched meme deltas to the local widget snapshot.
final class ApplyMemeWidgetPushDeltaUsecase {
  /// Creates the usecase.
  const ApplyMemeWidgetPushDeltaUsecase({
    required MemeWidgetLocalRepository localRepository,
  }) : _localRepository = localRepository;

  final MemeWidgetLocalRepository _localRepository;

  /// Maximum number of persisted widget items.
  static const int itemLimit = 5;

  /// Default background color (`MColors.gray900`).
  static const String _defaultBackgroundHex = '#191919';

  /// Default foreground color (`MColors.gray100`).
  static const String _defaultForegroundHex = '#FBFBFB';

  /// Applies [delta] into local snapshot state for [texts].
  Future<ApplyMemeWidgetPushDeltaResult> call({
    required MemeWidgetPushDeltaEntity delta,
    required MemeWidgetTextsEntity texts,
  }) async {
    if (!delta.isMemeNotification) {
      return const ApplyMemeWidgetPushDeltaResult(
        didApply: false,
        requiresSyncFallback: false,
      );
    }

    if (!delta.isCompleteForWidget) {
      return const ApplyMemeWidgetPushDeltaResult(
        didApply: false,
        requiresSyncFallback: true,
      );
    }

    final MemeWidgetSnapshotEntity? previousSnapshot = await _localRepository
        .loadSnapshot();

    final List<MemeWidgetItemEntity> previousItems =
        previousSnapshot?.items ?? const <MemeWidgetItemEntity>[];

    final MemeWidgetItemEntity? existingItem = _findItemById(
      previousItems,
      delta.memeId!,
    );
    final bool isInsertedMeme = existingItem == null;

    final String? cachedImagePath = await _resolveCachedImagePath(
      existingItem: existingItem,
      memeId: delta.memeId!,
      nextImageUrl: delta.imageUrlFull!,
    );

    final MemeWidgetItemEntity mergedItem = MemeWidgetItemEntity(
      memeId: delta.memeId!,
      creatorId: delta.creatorId!,
      creatorName: delta.creatorName!,
      laughCount: delta.laughCount!,
      isLaughed: delta.isLaughed!,
      isOwnMeme: delta.isOwnMeme!,
      aspectRatio: delta.aspectRatio!,
      imagePath: delta.imagePathFull!,
      imageUrlFull: delta.imageUrlFull!,
      androidCachedImagePath: cachedImagePath,
      backgroundHex: existingItem?.backgroundHex ?? _defaultBackgroundHex,
      foregroundHex: existingItem?.foregroundHex ?? _defaultForegroundHex,
    );

    final List<MemeWidgetItemEntity> mergedItems = <MemeWidgetItemEntity>[
      mergedItem,
      ...previousItems.where(
        (MemeWidgetItemEntity item) => item.memeId != mergedItem.memeId,
      ),
    ].take(itemLimit).toList(growable: false);

    final String? selectedMemeId = isInsertedMeme
        ? null
        : _resolveSelectedMemeId(previousSnapshot);
    final int selectedIndex = _resolveSelectedIndex(
      items: mergedItems,
      selectedMemeId: selectedMemeId,
    );

    final MemeWidgetSnapshotEntity nextSnapshot = MemeWidgetSnapshotEntity(
      status: MemeWidgetSnapshotStatus.ready,
      items: List<MemeWidgetItemEntity>.unmodifiable(mergedItems),
      selectedIndex: selectedIndex,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      pendingLaughMemeId: _resolvePendingLaughMemeId(
        previousPendingMemeId: previousSnapshot?.pendingLaughMemeId,
        updatedMemeId: delta.memeId!,
      ),
      emptyText: previousSnapshot?.emptyText ?? texts.emptyText,
      signedOutText: previousSnapshot?.signedOutText ?? texts.signedOutText,
      laughActionText:
          previousSnapshot?.laughActionText ?? texts.laughActionText,
      unlaughActionText:
          previousSnapshot?.unlaughActionText ?? texts.unlaughActionText,
      ownerActionText:
          previousSnapshot?.ownerActionText ?? texts.ownerActionText,
    );

    await _localRepository.saveSnapshot(nextSnapshot);
    await _localRepository.refreshNativeWidget();

    return const ApplyMemeWidgetPushDeltaResult(
      didApply: true,
      requiresSyncFallback: false,
    );
  }

  String? _resolvePendingLaughMemeId({
    required String? previousPendingMemeId,
    required String updatedMemeId,
  }) {
    if (previousPendingMemeId == null || previousPendingMemeId.isEmpty) {
      return null;
    }

    if (previousPendingMemeId == updatedMemeId) {
      return null;
    }

    return previousPendingMemeId;
  }

  Future<String?> _resolveCachedImagePath({
    required MemeWidgetItemEntity? existingItem,
    required String memeId,
    required String nextImageUrl,
  }) async {
    if (existingItem == null) {
      return MemeWidgetImageCache.cacheImageFromUrl(
        memeId: memeId,
        imageUrl: nextImageUrl,
      );
    }

    if (existingItem.imageUrlFull == nextImageUrl &&
        await MemeWidgetImageCache.isUsablePath(
          existingItem.androidCachedImagePath,
        )) {
      return MemeWidgetImageCache.normalizePath(
        existingItem.androidCachedImagePath,
      );
    }

    return MemeWidgetImageCache.cacheImageFromUrl(
      memeId: memeId,
      imageUrl: nextImageUrl,
    );
  }

  String? _resolveSelectedMemeId(MemeWidgetSnapshotEntity? previousSnapshot) {
    if (previousSnapshot == null || previousSnapshot.items.isEmpty) {
      return null;
    }

    final int index = previousSnapshot.safeSelectedIndex;
    return previousSnapshot.items[index].memeId;
  }

  int _resolveSelectedIndex({
    required List<MemeWidgetItemEntity> items,
    required String? selectedMemeId,
  }) {
    if (items.isEmpty) {
      return 0;
    }

    if (selectedMemeId == null || selectedMemeId.isEmpty) {
      return 0;
    }

    final int index = items.indexWhere(
      (MemeWidgetItemEntity item) => item.memeId == selectedMemeId,
    );

    if (index < 0) {
      return 0;
    }

    return index;
  }

  MemeWidgetItemEntity? _findItemById(
    List<MemeWidgetItemEntity> items,
    String memeId,
  ) {
    for (final MemeWidgetItemEntity item in items) {
      if (item.memeId == memeId) {
        return item;
      }
    }

    return null;
  }
}
