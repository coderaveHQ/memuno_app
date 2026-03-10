import 'package:memuno_app/src/features/user_details/application/providers/user_details_repository_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/get_user_details_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_user_details_usecase_provider.g.dart';

/// Provides the [GetUserDetailsUsecase] usecase.
@riverpod
GetUserDetailsUsecase getUserDetailsUsecase(Ref ref) {
  final UserDetailsRepository repository = ref.watch(
    userDetailsRepositoryProvider,
  );
  return GetUserDetailsUsecase(repository: repository);
}
