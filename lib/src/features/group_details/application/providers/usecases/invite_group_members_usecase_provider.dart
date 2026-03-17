import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/invite_group_members_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invite_group_members_usecase_provider.g.dart';

/// Provides the invite-group-members usecase.
@Riverpod(keepAlive: true)
InviteGroupMembersUsecase inviteGroupMembersUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return InviteGroupMembersUsecase(repository: repository);
}
