import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_datasource_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_user_mapper_provider.dart';
import 'package:memuno_app/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:memuno_app/src/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:memuno_app/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_provider.g.dart';

/// Provides the [AuthRepository].
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  /// Auth datasource dependency.
  final AuthDatasource authDatasource = ref.watch(authDatasourceProvider);

  /// Mapper for DTO → domain conversion.
  final AuthUserMapper authUserMapper = ref.watch(authUserMapperProvider);

  /// Mapper for normalizing failures.
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);
  // Construct the repository with its dependencies.
  return AuthRepositoryImpl(
    authDatasource: authDatasource,
    authUserMapper: authUserMapper,
    failureMapper: failureMapper,
  );
}
