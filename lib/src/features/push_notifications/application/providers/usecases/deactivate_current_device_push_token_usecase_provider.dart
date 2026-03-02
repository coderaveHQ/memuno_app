import 'package:memuno_app/src/features/push_notifications/application/providers/push_token_repository_provider.dart';
import 'package:memuno_app/src/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deactivate_current_device_push_token_usecase_provider.g.dart';

/// Provides [DeactivateCurrentDevicePushTokenUsecase].
@riverpod
DeactivateCurrentDevicePushTokenUsecase deactivateCurrentDevicePushTokenUsecase(
  Ref ref,
) {
  final PushTokenRepository pushTokenRepository = ref.watch(
    pushTokenRepositoryProvider,
  );

  return DeactivateCurrentDevicePushTokenUsecase(
    pushTokenRepository: pushTokenRepository,
  );
}
