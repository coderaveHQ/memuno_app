import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_action_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/set_meme_widget_selected_index_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/toggle_meme_widget_laugh_usecase.dart';

/// Output model for widget action handling.
final class MemeWidgetActionResult {
  /// Creates a result instance.
  const MemeWidgetActionResult({required this.shouldOpenApp, this.openMemeId});

  /// Whether the app should be opened to default route.
  final bool shouldOpenApp;

  /// Optional meme id to open in details route.
  final String? openMemeId;
}

/// Usecase for handling one parsed widget action.
final class HandleMemeWidgetActionUsecase {
  /// Creates the usecase.
  const HandleMemeWidgetActionUsecase({
    required SyncMemeWidgetUsecase syncUsecase,
    required ToggleMemeWidgetLaughUsecase toggleLaughUsecase,
    required SetMemeWidgetSelectedIndexUsecase setSelectedIndexUsecase,
    required MemeWidgetLocalRepository localRepository,
  }) : _syncUsecase = syncUsecase,
       _toggleLaughUsecase = toggleLaughUsecase,
       _setSelectedIndexUsecase = setSelectedIndexUsecase,
       _localRepository = localRepository;

  final SyncMemeWidgetUsecase _syncUsecase;
  final ToggleMemeWidgetLaughUsecase _toggleLaughUsecase;
  final SetMemeWidgetSelectedIndexUsecase _setSelectedIndexUsecase;
  final MemeWidgetLocalRepository _localRepository;

  /// Executes [action] and returns navigation hints.
  Future<MemeWidgetActionResult> call({
    required MemeWidgetActionEntity action,
    required MemeWidgetTextsEntity texts,
  }) async {
    switch (action.type) {
      case MemeWidgetActionType.openApp:
        return const MemeWidgetActionResult(shouldOpenApp: true);
      case MemeWidgetActionType.openMeme:
        return MemeWidgetActionResult(
          shouldOpenApp: false,
          openMemeId: action.memeId,
        );
      case MemeWidgetActionType.laugh:
        final String? memeId = action.memeId;
        if (memeId != null && memeId.isNotEmpty) {
          await _toggleLaughWithOptimisticState(memeId: memeId, texts: texts);
        }
        return MemeWidgetActionResult(openMemeId: memeId, shouldOpenApp: false);
      case MemeWidgetActionType.previous:
        await _moveIndexBy(delta: -1);
        return const MemeWidgetActionResult(shouldOpenApp: false);
      case MemeWidgetActionType.next:
        await _moveIndexBy(delta: 1);
        return const MemeWidgetActionResult(shouldOpenApp: false);
      case MemeWidgetActionType.unknown:
        return const MemeWidgetActionResult(shouldOpenApp: false);
    }
  }

  Future<void> _toggleLaughWithOptimisticState({
    required String memeId,
    required MemeWidgetTextsEntity texts,
  }) async {
    final MemeWidgetSnapshotEntity? snapshot = await _localRepository
        .loadSnapshot();
    if (snapshot == null || snapshot.items.isEmpty) {
      return;
    }

    final String? pendingMemeId = snapshot.pendingLaughMemeId;
    if (pendingMemeId != null && pendingMemeId.isNotEmpty) {
      return;
    }

    final int itemIndex = snapshot.items.indexWhere(
      (MemeWidgetItemEntity item) => item.memeId == memeId,
    );
    if (itemIndex < 0) {
      return;
    }

    final MemeWidgetItemEntity currentItem = snapshot.items[itemIndex];
    if (currentItem.isOwnMeme) {
      return;
    }

    final MemeWidgetItemEntity optimisticItem = _buildOptimisticLaughItem(
      item: currentItem,
    );
    final List<MemeWidgetItemEntity> optimisticItems =
        List<MemeWidgetItemEntity>.from(snapshot.items)
          ..[itemIndex] = optimisticItem;

    final MemeWidgetSnapshotEntity optimisticSnapshot = snapshot.copyWith(
      items: List<MemeWidgetItemEntity>.unmodifiable(optimisticItems),
      pendingLaughMemeId: memeId,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );

    await _localRepository.saveSnapshot(optimisticSnapshot);
    await _localRepository.refreshNativeWidget();

    try {
      await _toggleLaughUsecase(memeId: memeId);
      await _syncUsecase(texts: texts);
    } catch (_) {
      await _localRepository.saveSnapshot(
        snapshot.copyWith(
          clearPendingLaughMemeId: true,
          updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await _localRepository.refreshNativeWidget();
    }
  }

  MemeWidgetItemEntity _buildOptimisticLaughItem({
    required MemeWidgetItemEntity item,
  }) {
    final bool nextIsLaughed = !item.isLaughed;
    final int nextLaughCount = nextIsLaughed
        ? item.laughCount + 1
        : (item.laughCount > 0 ? item.laughCount - 1 : 0);

    return item.copyWith(isLaughed: nextIsLaughed, laughCount: nextLaughCount);
  }

  Future<void> _moveIndexBy({required int delta}) async {
    final MemeWidgetSnapshotEntity? snapshot = await _localRepository
        .loadSnapshot();
    if (snapshot == null || snapshot.items.isEmpty) {
      return;
    }

    final int itemCount = snapshot.items.length;
    final int current = snapshot.safeSelectedIndex;
    final int next = (current + delta) % itemCount;
    final int normalized = next < 0 ? next + itemCount : next;

    await _setSelectedIndexUsecase(selectedIndex: normalized);
  }
}
