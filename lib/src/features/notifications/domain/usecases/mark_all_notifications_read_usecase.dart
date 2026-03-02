import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Usecase for marking all notifications as read.
final class MarkAllNotificationsReadUsecase {
  /// Creates the usecase.
  const MarkAllNotificationsReadUsecase({
    required NotificationsRepository repository,
  }) : _repository = repository;

  final NotificationsRepository _repository;

  /// Marks all unread notifications as read and returns affected row count.
  Future<int> call() {
    return _repository.markAllNotificationsRead();
  }
}
