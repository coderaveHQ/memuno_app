import 'package:memuno_app/src/features/group_details/application/providers/usecases/get_group_details_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/get_group_details_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_provider.g.dart';

/// Loads one group-details payload.
@riverpod
Future<GroupDetailsEntity> groupDetails(Ref ref, String groupId) async {
  final GetGroupDetailsUsecase usecase = ref.watch(
    getGroupDetailsUsecaseProvider,
  );
  return usecase(groupId: groupId);
}
