import 'package:memuno_app/src/features/groups/application/providers/groups_repository_provider.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_group_usecase_provider.g.dart';

/// Provides [CreateGroupUsecase].
@riverpod
CreateGroupUsecase createGroupUsecase(Ref ref) {
  final GroupsRepository repository = ref.watch(groupsRepositoryProvider);
  return CreateGroupUsecase(repository: repository);
}
