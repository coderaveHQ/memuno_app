import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accept_friendship_request_mutation.g.dart';

/// Mutation: accept one incoming friendship request.
@riverpod
Mutation<FriendshipEntity> acceptFriendshipRequestMutation(
  Ref ref,
  String requestId,
) {
  return Mutation<FriendshipEntity>(
    label: 'accept_friendship_request:$requestId',
  );
}
