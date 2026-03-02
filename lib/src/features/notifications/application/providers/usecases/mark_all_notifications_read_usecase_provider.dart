import 'package:memuno_app/src/features/notifications/application/providers/notifications_repository_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mark_all_notifications_read_usecase_provider.g.dart';

/// Provides [MarkAllNotificationsReadUsecase].
@riverpod
MarkAllNotificationsReadUsecase markAllNotificationsReadUsecase(Ref ref) {
  final NotificationsRepository repository = ref.watch(
    notificationsRepositoryProvider,
  );
  return MarkAllNotificationsReadUsecase(repository: repository);
}
