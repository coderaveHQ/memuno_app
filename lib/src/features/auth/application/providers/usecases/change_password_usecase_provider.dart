import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_usecase_provider.g.dart';

/// Provides the [ChangePasswordUsecase] usecase.
@riverpod
ChangePasswordUsecase changePasswordUsecase(Ref ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  final Validator validator = ref.watch(validatorProvider);
  return ChangePasswordUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
