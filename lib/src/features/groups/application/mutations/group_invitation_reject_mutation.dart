import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_invitation_reject_mutation.g.dart';

/// Mutation: reject one incoming group invitation.
@riverpod
Mutation<void> groupInvitationRejectMutation(Ref ref, String invitationId) {
  return Mutation<void>(label: 'group_invitation_reject:$invitationId');
}
