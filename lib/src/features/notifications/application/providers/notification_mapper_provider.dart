import 'package:memuno_app/src/features/notifications/data/mappers/notification_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_mapper_provider.g.dart';

/// Provides [NotificationMapper].
@Riverpod(keepAlive: true)
NotificationMapper notificationMapper(Ref ref) {
  return const NotificationMapper();
}
