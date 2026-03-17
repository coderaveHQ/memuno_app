import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_update_name_mutation.g.dart';

/// Mutation: update one group name from group-details info page.
@riverpod
Mutation<void> groupDetailsUpdateNameMutation(Ref ref, String groupId) {
  return Mutation<void>(label: 'group_details_update_name:$groupId');
}
