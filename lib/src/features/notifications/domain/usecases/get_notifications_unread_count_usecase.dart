import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Usecase for reading the unread notifications count.
final class GetNotificationsUnreadCountUsecase {
  /// Creates the usecase.
  const GetNotificationsUnreadCountUsecase({
    required NotificationsRepository repository,
  }) : _repository = repository;

  final NotificationsRepository _repository;

  /// Returns unread notifications count for the current user.
  Future<int> call() {
    return _repository.unreadNotificationsCount();
  }
}
