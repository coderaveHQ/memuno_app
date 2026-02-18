import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cancel_friendship_request_mutation.g.dart';

/// Mutation: cancel one outgoing friendship request.
@riverpod
Mutation<void> cancelFriendshipRequestMutation(Ref ref, String requestId) {
  return Mutation<void>(label: 'cancel_friendship_request:$requestId');
}
