import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_datasource_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_mapper_provider.dart';
import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/features/user_details/data/mappers/user_details_mapper.dart';
import 'package:memuno_app/src/features/user_details/data/repositories/user_details_repository_impl.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_repository_provider.g.dart';

/// Provides the user-details repository.
@Riverpod(keepAlive: true)
UserDetailsRepository userDetailsRepository(Ref ref) {
  final UserDetailsDatasource userDetailsDatasource = ref.watch(
    userDetailsDatasourceProvider,
  );
  final UserDetailsMapper userDetailsMapper = ref.watch(
    userDetailsMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return UserDetailsRepositoryImpl(
    userDetailsDatasource: userDetailsDatasource,
    userDetailsMapper: userDetailsMapper,
    failureMapper: failureMapper,
  );
}
