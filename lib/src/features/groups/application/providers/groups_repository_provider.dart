import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/group_invitation_mapper_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/group_mapper_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/groups_datasource_provider.dart';
import 'package:memuno_app/src/features/groups/data/datasources/groups_datasource.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_invitation_mapper.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_mapper.dart';
import 'package:memuno_app/src/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'groups_repository_provider.g.dart';

/// Provides the groups repository implementation.
@Riverpod(keepAlive: true)
GroupsRepository groupsRepository(Ref ref) {
  final GroupsDatasource groupsDatasource = ref.watch(groupsDatasourceProvider);
  final GroupMapper groupMapper = ref.watch(groupMapperProvider);
  final GroupInvitationMapper groupInvitationMapper = ref.watch(
    groupInvitationMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return GroupsRepositoryImpl(
    groupsDatasource: groupsDatasource,
    groupMapper: groupMapper,
    groupInvitationMapper: groupInvitationMapper,
    failureMapper: failureMapper,
  );
}
