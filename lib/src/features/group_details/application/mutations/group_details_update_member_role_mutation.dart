import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_update_member_role_mutation.g.dart';

/// Mutation: update one member role in group-details info page.
@riverpod
Mutation<void> groupDetailsUpdateMemberRoleMutation(Ref ref, String memberKey) {
  return Mutation<void>(label: 'group_details_update_member_role:$memberKey');
}
