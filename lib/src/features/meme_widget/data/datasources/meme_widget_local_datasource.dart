import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';

/// Local datasource contract for widget state sharing.
abstract interface class MemeWidgetLocalDatasource {
  /// Configures native widget integration.
  Future<void> configure();

  /// Persists [snapshot] to shared widget storage.
  Future<void> saveSnapshot(MemeWidgetSnapshotEntity snapshot);

  /// Loads previously persisted widget snapshot.
  Future<MemeWidgetSnapshotEntity?> loadSnapshot();

  /// Clears persisted snapshot payload.
  Future<void> clearSnapshot();

  /// Stores one deferred action URI.
  Future<void> savePendingActionUri(String actionUri);

  /// Reads and clears one deferred action URI.
  Future<String?> takePendingActionUri();

  /// Triggers native widget redraw/update.
  Future<void> refreshNativeWidget();

  /// Stream of click URIs emitted by the host widget plugin.
  Stream<Uri> widgetClickedStream();

  /// Returns launch URI when app was started from a widget.
  Future<Uri?> initiallyLaunchedUri();
}
