import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/change_email_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_email_usecase_provider.g.dart';

/// Provides the [ChangeEmailUsecase] usecase.
@riverpod
ChangeEmailUsecase changeEmailUsecase(Ref ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  final Validator validator = ref.watch(validatorProvider);
  return ChangeEmailUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
