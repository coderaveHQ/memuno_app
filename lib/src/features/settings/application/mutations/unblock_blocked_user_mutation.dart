import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unblock_blocked_user_mutation.g.dart';

/// Mutation: unblock one user from blocked-users settings page.
@riverpod
Mutation<void> unblockBlockedUserMutation(Ref ref, String userId) {
  return Mutation<void>(label: 'unblock_blocked_user:$userId');
}
