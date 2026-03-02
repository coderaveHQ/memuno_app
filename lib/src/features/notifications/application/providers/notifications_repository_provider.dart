import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notification_mapper_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_datasource_provider.dart';
import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/mappers/notification_mapper.dart';
import 'package:memuno_app/src/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:memuno_app/src/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_repository_provider.g.dart';

/// Provides the notifications repository implementation.
@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  final NotificationsDatasource datasource = ref.watch(
    notificationsDatasourceProvider,
  );
  final NotificationMapper mapper = ref.watch(notificationMapperProvider);
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return NotificationsRepositoryImpl(
    notificationsDatasource: datasource,
    notificationMapper: mapper,
    failureMapper: failureMapper,
  );
}
