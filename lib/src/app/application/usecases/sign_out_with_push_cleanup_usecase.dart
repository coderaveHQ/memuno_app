import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';

/// App-level sign-out orchestration:
/// 1) best-effort push token deactivation
/// 2) auth sign-out
final class SignOutWithPushCleanupUsecase {
  /// Creates the usecase.
  const SignOutWithPushCleanupUsecase({
    required SignOutUsecase signOutUsecase,
    required DeactivateCurrentDevicePushTokenUsecase
    deactivateCurrentDevicePushTokenUsecase,
    required Logger logger,
  }) : _signOutUsecase = signOutUsecase,
       _deactivateCurrentDevicePushTokenUsecase =
           deactivateCurrentDevicePushTokenUsecase,
       _logger = logger;

  final SignOutUsecase _signOutUsecase;
  final DeactivateCurrentDevicePushTokenUsecase
  _deactivateCurrentDevicePushTokenUsecase;
  final Logger _logger;

  /// Executes sign-out with best-effort push cleanup.
  Future<void> call() async {
    try {
      await _deactivateCurrentDevicePushTokenUsecase(
        reason: PushTokenDeactivationReason.signedOut,
      );
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to deactivate push token before sign-out.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _signOutUsecase();
  }
}
