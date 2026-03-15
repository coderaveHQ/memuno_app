import 'package:memuno_app/src/features/user_details/application/providers/user_details_repository_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/toggle_user_details_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_user_details_meme_laugh_usecase_provider.g.dart';

/// Provides [ToggleUserDetailsMemeLaughUsecase].
@riverpod
ToggleUserDetailsMemeLaughUsecase toggleUserDetailsMemeLaughUsecase(Ref ref) {
  final UserDetailsRepository repository = ref.watch(
    userDetailsRepositoryProvider,
  );
  return ToggleUserDetailsMemeLaughUsecase(repository: repository);
}
