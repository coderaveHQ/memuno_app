import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:memuno_app/src/features/push_notifications/domain/repositories/push_token_repository.dart';

/// Usecase: deactivate current-device push tokens.
final class DeactivateCurrentDevicePushTokenUsecase {
  /// Creates the usecase.
  const DeactivateCurrentDevicePushTokenUsecase({
    required PushTokenRepository pushTokenRepository,
  }) : _pushTokenRepository = pushTokenRepository;

  /// Repository dependency.
  final PushTokenRepository _pushTokenRepository;

  /// Soft-deactivates active tokens for the current installation.
  Future<void> call({required PushTokenDeactivationReason reason}) {
    return _pushTokenRepository.deactivateCurrentDeviceToken(reason: reason);
  }
}
