import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_in_with_otp_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_with_otp_usecase_provider.g.dart';

/// Provides the [SignInWithOtpUsecase] usecase.
@riverpod
SignInWithOtpUsecase signInWithOtpUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  /// Validator dependency for local input checks.
  final Validator validator = ref.watch(validatorProvider);
  // Construct the usecase with its dependencies.
  return SignInWithOtpUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
