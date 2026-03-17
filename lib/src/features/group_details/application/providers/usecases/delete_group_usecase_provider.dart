import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/delete_group_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_group_usecase_provider.g.dart';

/// Provides the delete-group usecase.
@Riverpod(keepAlive: true)
DeleteGroupUsecase deleteGroupUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return DeleteGroupUsecase(repository: repository);
}
