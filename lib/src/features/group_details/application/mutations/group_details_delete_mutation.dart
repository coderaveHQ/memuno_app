import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_delete_mutation.g.dart';

/// Mutation: delete one group from group-details info page.
@riverpod
Mutation<void> groupDetailsDeleteMutation(Ref ref, String groupId) {
  return Mutation<void>(label: 'group_details_delete:$groupId');
}
