import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mark_notification_read_mutation.g.dart';

/// Mutation: mark a single notification as read.
@riverpod
Mutation<void> markNotificationReadMutation(Ref ref, String notificationId) {
  return Mutation<void>(label: 'mark_notification_read:$notificationId');
}
