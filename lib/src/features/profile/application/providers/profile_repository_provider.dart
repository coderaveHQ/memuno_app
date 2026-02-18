import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/profile/application/providers/profile_datasource_provider.dart';
import 'package:memuno_app/src/features/profile/application/providers/user_profile_mapper_provider.dart';
import 'package:memuno_app/src/features/profile/data/datasources/profile_datasource.dart';
import 'package:memuno_app/src/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:memuno_app/src/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_provider.g.dart';

/// Provides the profile repository.
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final ProfileDatasource profileDatasource = ref.watch(
    profileDatasourceProvider,
  );
  final UserProfileMapper userProfileMapper = ref.watch(
    userProfileMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return ProfileRepositoryImpl(
    profileDatasource: profileDatasource,
    userProfileMapper: userProfileMapper,
    failureMapper: failureMapper,
  );
}
