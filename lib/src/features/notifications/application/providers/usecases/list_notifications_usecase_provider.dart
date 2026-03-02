import 'package:memuno_app/src/features/notifications/application/providers/notifications_repository_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/list_notifications_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_notifications_usecase_provider.g.dart';

/// Provides [ListNotificationsUsecase].
@riverpod
ListNotificationsUsecase listNotificationsUsecase(Ref ref) {
  final NotificationsRepository repository = ref.watch(
    notificationsRepositoryProvider,
  );
  return ListNotificationsUsecase(repository: repository);
}
