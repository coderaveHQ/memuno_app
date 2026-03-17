import 'package:memuno_app/src/features/groups/application/providers/groups_repository_provider.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/leave_group_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leave_group_usecase_provider.g.dart';

/// Provides [LeaveGroupUsecase].
@riverpod
LeaveGroupUsecase leaveGroupUsecase(Ref ref) {
  final GroupsRepository repository = ref.watch(groupsRepositoryProvider);
  return LeaveGroupUsecase(repository: repository);
}
