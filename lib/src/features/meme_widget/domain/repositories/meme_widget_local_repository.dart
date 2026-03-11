import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';

/// Repository contract for local widget persistence and platform updates.
abstract interface class MemeWidgetLocalRepository {
  /// Configures local widget integration (app groups/callback registration).
  Future<void> configure();

  /// Persists [snapshot] in shared widget storage.
  Future<void> saveSnapshot(MemeWidgetSnapshotEntity snapshot);

  /// Loads previously persisted snapshot, if available.
  Future<MemeWidgetSnapshotEntity?> loadSnapshot();

  /// Removes all persisted widget snapshot data.
  Future<void> clearSnapshot();

  /// Stores pending action URI payload for deferred execution.
  Future<void> savePendingActionUri(String actionUri);

  /// Reads and clears a pending action URI payload.
  Future<String?> takePendingActionUri();

  /// Triggers widget refresh on native platforms.
  Future<void> refreshNativeWidget();

  /// Stream of click URIs emitted by the widget plugin.
  Stream<Uri> widgetClickedStream();

  /// Returns launch URI if app was started from a widget interaction.
  Future<Uri?> initiallyLaunchedUri();
}
