import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_cancel_invitation_mutation.g.dart';

/// Mutation: cancel one pending invitation from group-details info page.
@riverpod
Mutation<void> groupDetailsCancelInvitationMutation(
  Ref ref,
  String invitationId,
) {
  return Mutation<void>(label: 'group_details_cancel_invitation:$invitationId');
}
