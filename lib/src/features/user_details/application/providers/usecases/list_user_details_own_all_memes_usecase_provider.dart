import 'package:memuno_app/src/features/user_details/application/providers/user_details_repository_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/list_user_details_own_all_memes_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_user_details_own_all_memes_usecase_provider.g.dart';

/// Provides [ListUserDetailsOwnAllMemesUsecase].
@riverpod
ListUserDetailsOwnAllMemesUsecase listUserDetailsOwnAllMemesUsecase(Ref ref) {
  final UserDetailsRepository repository = ref.watch(
    userDetailsRepositoryProvider,
  );
  return ListUserDetailsOwnAllMemesUsecase(repository: repository);
}
