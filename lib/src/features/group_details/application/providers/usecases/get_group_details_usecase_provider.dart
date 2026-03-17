import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/get_group_details_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_group_details_usecase_provider.g.dart';

/// Provides the get-group-details usecase.
@Riverpod(keepAlive: true)
GetGroupDetailsUsecase getGroupDetailsUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return GetGroupDetailsUsecase(repository: repository);
}
