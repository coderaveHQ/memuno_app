import 'package:memuno_app/src/features/push_notifications/application/ports/push_sync_state_store.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_installation_local_datasource_provider.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/push_installation_local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_sync_state_store_provider.g.dart';

/// Provides persisted sync-state storage for push lifecycle operations.
@Riverpod(keepAlive: true)
PushSyncStateStore pushSyncStateStore(Ref ref) {
  final PushInstallationLocalDatasource datasource = ref.watch(
    pushInstallationLocalDatasourceProvider,
  );
  return datasource;
}
