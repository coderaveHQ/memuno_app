import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_datasource_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_mapper_provider.dart';
import 'package:memuno_app/src/features/group_details/data/datasources/group_details_datasource.dart';
import 'package:memuno_app/src/features/group_details/data/mappers/group_details_mapper.dart';
import 'package:memuno_app/src/features/group_details/data/repositories/group_details_repository_impl.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_repository_provider.g.dart';

/// Provides the group-details repository implementation.
@Riverpod(keepAlive: true)
GroupDetailsRepository groupDetailsRepository(Ref ref) {
  final GroupDetailsDatasource datasource = ref.watch(
    groupDetailsDatasourceProvider,
  );
  final GroupDetailsMapper mapper = ref.watch(groupDetailsMapperProvider);
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return GroupDetailsRepositoryImpl(
    groupDetailsDatasource: datasource,
    groupDetailsMapper: mapper,
    failureMapper: failureMapper,
  );
}
