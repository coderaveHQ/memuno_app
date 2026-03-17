import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_remove_member_mutation.g.dart';

/// Mutation: remove one member from group-details info page.
@riverpod
Mutation<void> groupDetailsRemoveMemberMutation(Ref ref, String memberKey) {
  return Mutation<void>(label: 'group_details_remove_member:$memberKey');
}
