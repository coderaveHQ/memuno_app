import 'package:memuno_app/src/features/profile/application/providers/profile_repository_provider.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:memuno_app/src/features/profile/domain/usecases/get_current_user_profile_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_current_user_profile_usecase_provider.g.dart';

/// Provides the [GetCurrentUserProfileUsecase] usecase.
@riverpod
GetCurrentUserProfileUsecase getCurrentUserProfileUsecase(Ref ref) {
  final ProfileRepository repository = ref.watch(profileRepositoryProvider);
  return GetCurrentUserProfileUsecase(repository: repository);
}
