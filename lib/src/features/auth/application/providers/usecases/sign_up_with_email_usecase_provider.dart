import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_with_email_usecase_provider.g.dart';

/// Provides the [SignUpWithEmailUsecase] usecase.
@riverpod
SignUpWithEmailUsecase signUpWithEmailUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  /// Validator dependency for local input checks.
  final Validator validator = ref.watch(validatorProvider);
  // Construct the usecase with its dependencies.
  return SignUpWithEmailUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
