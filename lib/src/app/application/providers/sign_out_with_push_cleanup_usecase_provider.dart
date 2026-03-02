import 'package:memuno_app/src/app/application/usecases/sign_out_with_push_cleanup_usecase.dart';
import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_out_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/usecases/deactivate_current_device_push_token_usecase_provider.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_with_push_cleanup_usecase_provider.g.dart';

/// Provides [SignOutWithPushCleanupUsecase].
@riverpod
SignOutWithPushCleanupUsecase signOutWithPushCleanupUsecase(Ref ref) {
  final SignOutUsecase signOutUsecase = ref.watch(signOutUsecaseProvider);
  final DeactivateCurrentDevicePushTokenUsecase deactivateUsecase = ref.watch(
    deactivateCurrentDevicePushTokenUsecaseProvider,
  );
  final Logger logger = ref.watch(loggerProvider);

  return SignOutWithPushCleanupUsecase(
    signOutUsecase: signOutUsecase,
    deactivateCurrentDevicePushTokenUsecase: deactivateUsecase,
    logger: logger,
  );
}
