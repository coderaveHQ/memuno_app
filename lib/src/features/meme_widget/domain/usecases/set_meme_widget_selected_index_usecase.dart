import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';

/// Usecase for updating selected widget item index.
final class SetMemeWidgetSelectedIndexUsecase {
  /// Creates the usecase.
  const SetMemeWidgetSelectedIndexUsecase({
    required MemeWidgetLocalRepository localRepository,
  }) : _localRepository = localRepository;

  final MemeWidgetLocalRepository _localRepository;

  /// Sets selected index to [selectedIndex] and refreshes native widgets.
  Future<void> call({required int selectedIndex}) async {
    final snapshot = await _localRepository.loadSnapshot();
    if (snapshot == null) {
      return;
    }

    final int safeIndex = snapshot.items.isEmpty
        ? 0
        : selectedIndex.clamp(0, snapshot.items.length - 1).toInt();

    await _localRepository.saveSnapshot(
      snapshot.copyWith(
        selectedIndex: safeIndex,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _localRepository.refreshNativeWidget();
  }
}
