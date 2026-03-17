import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/update_group_member_role_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_group_member_role_usecase_provider.g.dart';

/// Provides the update-group-member-role usecase.
@Riverpod(keepAlive: true)
UpdateGroupMemberRoleUsecase updateGroupMemberRoleUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return UpdateGroupMemberRoleUsecase(repository: repository);
}
