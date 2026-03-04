import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_dto.dart';
import 'package:memuno_app/src/features/notifications/data/mappers/notification_mapper.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';

/// Repository implementation for notification feature operations.
final class NotificationsRepositoryImpl implements NotificationsRepository {
  /// Creates the repository.
  const NotificationsRepositoryImpl({
    required NotificationsDatasource notificationsDatasource,
    required NotificationMapper notificationMapper,
    required FailureMapper failureMapper,
  }) : _notificationsDatasource = notificationsDatasource,
       _notificationMapper = notificationMapper,
       _failureMapper = failureMapper;

  final NotificationsDatasource _notificationsDatasource;
  final NotificationMapper _notificationMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads one notification-list page and maps to domain entities.
  Future<NotificationListPageEntity> listNotifications({
    String? search,
    required int limit,
    NotificationCursorEntity? cursor,
  }) async {
    try {
      final NotificationListPageDto dto = await _notificationsDatasource
          .listNotifications(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _notificationMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Marks one notification as read.
  Future<void> markNotificationRead({required String notificationId}) async {
    try {
      await _notificationsDatasource.markNotificationRead(
        notificationId: notificationId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Marks all unread notifications as read and returns affected row count.
  Future<int> markAllNotificationsRead() async {
    try {
      return _notificationsDatasource.markAllNotificationsRead();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
