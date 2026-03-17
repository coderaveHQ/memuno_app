import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/list_group_details_memes_all_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_group_details_memes_all_usecase_provider.g.dart';

/// Provides the list-group-details-memes-all usecase.
@Riverpod(keepAlive: true)
ListGroupDetailsMemesAllUsecase listGroupDetailsMemesAllUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return ListGroupDetailsMemesAllUsecase(repository: repository);
}
