/// Port for persisting pending push-sync state between app sessions.
abstract interface class PushSyncStateStore {
  /// Returns whether a token sync retry is pending.
  bool loadSyncPending();

  /// Persists whether a token sync retry is pending.
  Future<void> saveSyncPending(bool value);
}
