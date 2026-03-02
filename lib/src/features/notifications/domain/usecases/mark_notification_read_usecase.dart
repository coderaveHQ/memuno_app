import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Usecase for marking a single notification as read.
final class MarkNotificationReadUsecase {
  /// Creates the usecase.
  const MarkNotificationReadUsecase({
    required NotificationsRepository repository,
  }) : _repository = repository;

  final NotificationsRepository _repository;

  /// Marks one notification as read.
  Future<void> call({required String notificationId}) {
    return _repository.markNotificationRead(notificationId: notificationId);
  }
}
