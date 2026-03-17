import 'package:flutter/foundation.dart';

/// Local state entity used by the group-create sheet flow.
@immutable
final class GroupCreateDraftStateEntity {
  const GroupCreateDraftStateEntity({
    required this.name,
    required this.selectedInviteeUserIds,
  });

  final String name;
  final Set<String> selectedInviteeUserIds;

  String get trimmedName => name.trim();

  bool get canProceedFromNameStep {
    final String value = trimmedName;
    return value.isNotEmpty && value.length <= 64;
  }

  GroupCreateDraftStateEntity copyWith({
    String? name,
    Set<String>? selectedInviteeUserIds,
  }) {
    return GroupCreateDraftStateEntity(
      name: name ?? this.name,
      selectedInviteeUserIds:
          selectedInviteeUserIds ?? this.selectedInviteeUserIds,
    );
  }

  static const GroupCreateDraftStateEntity initial =
      GroupCreateDraftStateEntity(name: '', selectedInviteeUserIds: <String>{});
}
