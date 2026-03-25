import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_moderation_mutations.g.dart';

/// Mutation: report one user from user-details page.
@riverpod
Mutation<void> reportUserMutation(Ref ref, String userId) {
  return Mutation<void>(label: 'report_user:$userId');
}

/// Mutation: block one user from user-details page.
@riverpod
Mutation<void> blockUserMutation(Ref ref, String userId) {
  return Mutation<void>(label: 'block_user:$userId');
}

/// Mutation: unblock one user from user-details page.
@riverpod
Mutation<void> unblockUserMutation(Ref ref, String userId) {
  return Mutation<void>(label: 'unblock_user:$userId');
}
