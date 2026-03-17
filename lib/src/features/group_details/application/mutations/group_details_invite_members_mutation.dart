import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_invite_members_mutation.g.dart';

/// Mutation: invite one or more members from group-details info page.
@riverpod
Mutation<void> groupDetailsInviteMembersMutation(Ref ref, String groupId) {
  return Mutation<void>(label: 'group_details_invite_members:$groupId');
}
