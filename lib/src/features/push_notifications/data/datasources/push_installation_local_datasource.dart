import 'package:memuno_app/src/features/push_notifications/application/ports/push_sync_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Local persistence contract for push installation state.
abstract interface class PushInstallationLocalDatasource
    implements PushSyncStateStore {
  /// Returns the persisted installation id if available.
  String? loadInstallationId();

  /// Returns one stable installation id and creates it if needed.
  Future<String> getOrCreateInstallationId();

  /// Returns whether a token sync retry is pending.
  @override
  bool loadSyncPending();

  /// Persists the pending-sync marker.
  @override
  Future<void> saveSyncPending(bool value);
}

/// SharedPreferences-backed [PushInstallationLocalDatasource].
final class PushInstallationLocalDatasourceImpl
    implements PushInstallationLocalDatasource {
  /// Creates the datasource.
  const PushInstallationLocalDatasourceImpl({
    required SharedPreferences sharedPreferences,
    required Uuid uuid,
  }) : _sharedPreferences = sharedPreferences,
       _uuid = uuid;

  static const String _installationIdKey = 'push.installation_id';
  static const String _syncPendingKey = 'push.sync_pending';

  final SharedPreferences _sharedPreferences;
  final Uuid _uuid;

  @override
  String? loadInstallationId() {
    return _sharedPreferences.getString(_installationIdKey);
  }

  @override
  Future<String> getOrCreateInstallationId() async {
    final String? existing = loadInstallationId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final String installationId = _uuid.v4();
    await _sharedPreferences.setString(_installationIdKey, installationId);
    return installationId;
  }

  @override
  bool loadSyncPending() {
    return _sharedPreferences.getBool(_syncPendingKey) ?? false;
  }

  @override
  Future<void> saveSyncPending(bool value) async {
    await _sharedPreferences.setBool(_syncPendingKey, value);
  }
}
