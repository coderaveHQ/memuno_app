import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/get_notifications_unread_count_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/get_notifications_unread_count_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_unread_count_provider.g.dart';

/// Async provider for unread notifications count.
@Riverpod(keepAlive: true)
class NotificationsUnreadCount extends _$NotificationsUnreadCount {
  @override
  Future<int> build() async {
    final AuthUserEntity? user = ref.watch(currentUserProvider);
    if (user == null) {
      return 0;
    }

    final GetNotificationsUnreadCountUsecase usecase = ref.watch(
      getNotificationsUnreadCountUsecaseProvider,
    );
    return usecase();
  }

  /// Re-fetches unread count from the backend.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
