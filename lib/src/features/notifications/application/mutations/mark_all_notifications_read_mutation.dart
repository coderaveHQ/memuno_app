import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mark_all_notifications_read_mutation.g.dart';

/// Mutation: mark all notifications as read.
@riverpod
Mutation<void> markAllNotificationsReadMutation(Ref ref) {
  return Mutation<void>(label: 'mark_all_notifications_read');
}
