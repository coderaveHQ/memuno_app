import 'package:memuno_app/src/features/push_notifications/data/datasources/push_installation_local_datasource.dart';
import 'package:memuno_app/src/infrastructure/shared_preferences/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'push_installation_local_datasource_provider.g.dart';

/// Provides the local datasource for installation push state.
@Riverpod(keepAlive: true)
PushInstallationLocalDatasource pushInstallationLocalDatasource(Ref ref) {
  final SharedPreferences sharedPreferences = ref.watch(
    sharedPreferencesProvider,
  );

  return PushInstallationLocalDatasourceImpl(
    sharedPreferences: sharedPreferences,
    uuid: const Uuid(),
  );
}
