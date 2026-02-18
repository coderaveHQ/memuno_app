import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_friendship_mutation.g.dart';

/// Mutation: delete a friendship for one friend id.
@riverpod
Mutation<void> deleteFriendshipMutation(Ref ref, String friendId) {
  return Mutation<void>(label: 'delete_friendship:$friendId');
}
