import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_friendship_request_mutation.g.dart';

/// Mutation: create a new friendship request.
@riverpod
Mutation<FriendshipRequestListPageItemEntity> createFriendshipRequestMutation(
  Ref ref,
) {
  return Mutation<FriendshipRequestListPageItemEntity>(
    label: 'create_friendship_request',
  );
}
