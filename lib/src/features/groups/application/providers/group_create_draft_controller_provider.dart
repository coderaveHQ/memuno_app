import 'package:memuno_app/src/features/groups/domain/entities/group_create_draft_state_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create_draft_controller_provider.g.dart';

/// Local state controller for the group-create sheet flow.
@riverpod
class GroupCreateDraftController extends _$GroupCreateDraftController {
  @override
  GroupCreateDraftStateEntity build() {
    return GroupCreateDraftStateEntity.initial;
  }

  /// Updates the draft name value.
  void setName(String value) {
    state = state.copyWith(name: value);
  }

  /// Toggles invitee user selection by [userId].
  void toggleInvitee(String userId) {
    final Set<String> next = Set<String>.from(state.selectedInviteeUserIds);
    if (next.contains(userId)) {
      next.remove(userId);
    } else {
      next.add(userId);
    }

    state = state.copyWith(
      selectedInviteeUserIds: Set<String>.unmodifiable(next),
    );
  }

  /// Clears all selected invitees.
  void clearInvitees() {
    if (state.selectedInviteeUserIds.isEmpty) {
      return;
    }
    state = state.copyWith(selectedInviteeUserIds: const <String>{});
  }

  /// Resets the draft state.
  void reset() {
    state = GroupCreateDraftStateEntity.initial;
  }
}
