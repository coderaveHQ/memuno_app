import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_repository_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/update_current_user_details_name_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_current_user_details_name_usecase_provider.g.dart';

/// Provides the [UpdateCurrentUserDetailsNameUsecase] usecase.
@riverpod
UpdateCurrentUserDetailsNameUsecase updateCurrentUserDetailsNameUsecase(
  Ref ref,
) {
  final UserDetailsRepository repository = ref.watch(
    userDetailsRepositoryProvider,
  );
  final Validator validator = ref.watch(validatorProvider);

  return UpdateCurrentUserDetailsNameUsecase(
    repository: repository,
    validator: validator,
  );
}
