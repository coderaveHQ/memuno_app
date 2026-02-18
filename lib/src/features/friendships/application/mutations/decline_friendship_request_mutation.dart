import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decline_friendship_request_mutation.g.dart';

/// Mutation: decline one incoming friendship request.
@riverpod
Mutation<void> declineFriendshipRequestMutation(Ref ref, String requestId) {
  return Mutation<void>(label: 'decline_friendship_request:$requestId');
}
