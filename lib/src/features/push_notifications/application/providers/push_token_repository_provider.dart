import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_installation_local_datasource_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_token_datasource_provider.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/push_installation_local_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/push_token_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/data/repositories/push_token_repository_impl.dart';
import 'package:memuno_app/src/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_token_repository_provider.g.dart';

/// Provides the [PushTokenRepository].
@Riverpod(keepAlive: true)
PushTokenRepository pushTokenRepository(Ref ref) {
  final PushTokenDatasource pushTokenDatasource = ref.watch(
    pushTokenDatasourceProvider,
  );
  final PushInstallationLocalDatasource pushInstallationLocalDatasource = ref
      .watch(pushInstallationLocalDatasourceProvider);
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return PushTokenRepositoryImpl(
    pushTokenDatasource: pushTokenDatasource,
    pushInstallationLocalDatasource: pushInstallationLocalDatasource,
    failureMapper: failureMapper,
  );
}
