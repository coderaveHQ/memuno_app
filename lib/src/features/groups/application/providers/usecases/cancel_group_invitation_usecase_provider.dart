import 'package:memuno_app/src/features/groups/application/providers/groups_repository_provider.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/cancel_group_invitation_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cancel_group_invitation_usecase_provider.g.dart';

/// Provides [CancelGroupInvitationUsecase].
@riverpod
CancelGroupInvitationUsecase cancelGroupInvitationUsecase(Ref ref) {
  final GroupsRepository repository = ref.watch(groupsRepositoryProvider);
  return CancelGroupInvitationUsecase(repository: repository);
}
