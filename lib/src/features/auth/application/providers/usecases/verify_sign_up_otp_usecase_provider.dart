import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/verify_sign_up_otp_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_sign_up_otp_usecase_provider.g.dart';

/// Provides the [VerifySignUpOtpUsecase] usecase.
@riverpod
VerifySignUpOtpUsecase verifySignUpOtpUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  /// Validator dependency for local input checks.
  final Validator validator = ref.watch(validatorProvider);
  // Construct the usecase with its dependencies.
  return VerifySignUpOtpUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
