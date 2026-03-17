import 'package:memuno_app/src/features/groups/application/providers/groups_repository_provider.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/accept_group_invitation_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accept_group_invitation_usecase_provider.g.dart';

/// Provides [AcceptGroupInvitationUsecase].
@riverpod
AcceptGroupInvitationUsecase acceptGroupInvitationUsecase(Ref ref) {
  final GroupsRepository repository = ref.watch(groupsRepositoryProvider);
  return AcceptGroupInvitationUsecase(repository: repository);
}
