import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_leave_mutation.g.dart';

/// Mutation: leave one group from group-details info page.
@riverpod
Mutation<void> groupDetailsLeaveMutation(Ref ref, String groupId) {
  return Mutation<void>(label: 'group_details_leave:$groupId');
}
