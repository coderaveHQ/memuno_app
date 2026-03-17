import 'package:memuno_app/src/features/groups/application/providers/groups_repository_provider.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/list_groups_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_groups_usecase_provider.g.dart';

/// Provides [ListGroupsUsecase].
@riverpod
ListGroupsUsecase listGroupsUsecase(Ref ref) {
  final GroupsRepository repository = ref.watch(groupsRepositoryProvider);
  return ListGroupsUsecase(repository: repository);
}
