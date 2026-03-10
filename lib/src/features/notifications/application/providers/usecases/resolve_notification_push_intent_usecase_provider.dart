import 'package:memuno_app/src/features/notifications/domain/usecases/resolve_notification_push_intent_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resolve_notification_push_intent_usecase_provider.g.dart';

/// Provides the notification push-intent resolver usecase.
@riverpod
ResolveNotificationPushIntentUsecase resolveNotificationPushIntentUsecase(
  Ref ref,
) {
  return const ResolveNotificationPushIntentUsecase();
}
