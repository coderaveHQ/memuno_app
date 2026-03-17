/// Status values used by group invitations.
enum GroupInvitationStatus {
  /// Invitation exists and still requires action.
  pending,

  /// Invitation has been accepted.
  accepted,

  /// Invitation has been rejected by invitee.
  rejected,

  /// Invitation has been canceled by inviter/admin.
  canceled;

  /// Parses one database enum value to [GroupInvitationStatus].
  static GroupInvitationStatus fromDatabaseValue(String rawValue) {
    return switch (rawValue) {
      'pending' => GroupInvitationStatus.pending,
      'accepted' => GroupInvitationStatus.accepted,
      'rejected' => GroupInvitationStatus.rejected,
      'canceled' => GroupInvitationStatus.canceled,
      _ => throw FormatException(
        'Unknown group invitation status value: $rawValue',
      ),
    };
  }
}
