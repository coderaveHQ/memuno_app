import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accept_friendship_request_mutation.g.dart';

/// Mutation: accept one incoming friendship request.
@riverpod
Mutation<FriendshipListPageItemEntity> acceptFriendshipRequestMutation(
  Ref ref,
  String requestId,
) {
  return Mutation<FriendshipListPageItemEntity>(
    label: 'accept_friendship_request:$requestId',
  );
}
