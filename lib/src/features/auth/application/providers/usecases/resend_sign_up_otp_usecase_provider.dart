import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/resend_sign_up_otp_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resend_sign_up_otp_usecase_provider.g.dart';

/// Provides the [ResendSignUpOtpUsecase] usecase.
@riverpod
ResendSignUpOtpUsecase resendSignUpOtpUsecase(Ref ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  final Validator validator = ref.watch(validatorProvider);
  return ResendSignUpOtpUsecase(
    authRepository: authRepository,
    validator: validator,
  );
}
