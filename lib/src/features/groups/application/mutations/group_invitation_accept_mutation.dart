import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_invitation_accept_mutation.g.dart';

/// Mutation: accept one incoming group invitation.
@riverpod
Mutation<GroupItemEntity> groupInvitationAcceptMutation(
  Ref ref,
  String invitationId,
) {
  return Mutation<GroupItemEntity>(
    label: 'group_invitation_accept:$invitationId',
  );
}
