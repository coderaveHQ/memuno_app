import 'package:memuno_app/src/features/group_details/application/providers/group_details_repository_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/remove_group_member_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remove_group_member_usecase_provider.g.dart';

/// Provides the remove-group-member usecase.
@Riverpod(keepAlive: true)
RemoveGroupMemberUsecase removeGroupMemberUsecase(Ref ref) {
  final GroupDetailsRepository repository = ref.watch(
    groupDetailsRepositoryProvider,
  );
  return RemoveGroupMemberUsecase(repository: repository);
}
