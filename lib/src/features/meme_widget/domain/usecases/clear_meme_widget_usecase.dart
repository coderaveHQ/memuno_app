import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';

/// Usecase for clearing widget contents when no session exists.
final class ClearMemeWidgetUsecase {
  /// Creates the usecase.
  const ClearMemeWidgetUsecase({
    required MemeWidgetLocalRepository localRepository,
  }) : _localRepository = localRepository;

  final MemeWidgetLocalRepository _localRepository;

  /// Persists signed-out snapshot and refreshes native widgets.
  Future<void> call({required MemeWidgetTextsEntity texts}) async {
    await _localRepository.saveSnapshot(
      MemeWidgetSnapshotEntity(
        status: MemeWidgetSnapshotStatus.signedOut,
        items: const <Never>[],
        selectedIndex: 0,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        pendingLaughMemeId: null,
        emptyText: texts.emptyText,
        signedOutText: texts.signedOutText,
        laughActionText: texts.laughActionText,
        unlaughActionText: texts.unlaughActionText,
        ownerActionText: texts.ownerActionText,
      ),
    );
    await _localRepository.refreshNativeWidget();
  }
}
