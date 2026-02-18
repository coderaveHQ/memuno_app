import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/profile/application/providers/profile_repository_provider.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:memuno_app/src/features/profile/domain/usecases/update_current_user_name_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_current_user_name_usecase_provider.g.dart';

/// Provides the [UpdateCurrentUserNameUsecase] usecase.
@riverpod
UpdateCurrentUserNameUsecase updateCurrentUserNameUsecase(Ref ref) {
  final ProfileRepository repository = ref.watch(profileRepositoryProvider);
  final Validator validator = ref.watch(validatorProvider);

  return UpdateCurrentUserNameUsecase(
    repository: repository,
    validator: validator,
  );
}
