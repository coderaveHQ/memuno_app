import 'package:memuno_app/src/features/notifications/application/providers/notifications_repository_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mark_notification_read_usecase_provider.g.dart';

/// Provides [MarkNotificationReadUsecase].
@riverpod
MarkNotificationReadUsecase markNotificationReadUsecase(Ref ref) {
  final NotificationsRepository repository = ref.watch(
    notificationsRepositoryProvider,
  );
  return MarkNotificationReadUsecase(repository: repository);
}
