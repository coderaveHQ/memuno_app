import 'package:memuno_app/src/features/notifications/application/providers/notifications_repository_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/get_notifications_unread_count_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_notifications_unread_count_usecase_provider.g.dart';

/// Provides the unread-notifications-count usecase.
@riverpod
GetNotificationsUnreadCountUsecase getNotificationsUnreadCountUsecase(Ref ref) {
  final NotificationsRepository repository = ref.watch(
    notificationsRepositoryProvider,
  );

  return GetNotificationsUnreadCountUsecase(repository: repository);
}
