/// Reasons why a push token becomes inactive.
enum PushTokenDeactivationReason {
  /// User explicitly signed out.
  signedOut,

  /// Token was replaced by a newer token for the same installation.
  tokenRotated,

  /// Notification permission was revoked/denied.
  permissionRevoked,

  /// Sender reported the token as invalid.
  sendInvalid,

  /// User account was deleted.
  accountDeleted,

  /// Periodic cleanup removed stale data.
  cleanup;

  /// Database enum value.
  String get dbValue {
    return switch (this) {
      PushTokenDeactivationReason.signedOut => 'signed_out',
      PushTokenDeactivationReason.tokenRotated => 'token_rotated',
      PushTokenDeactivationReason.permissionRevoked => 'permission_revoked',
      PushTokenDeactivationReason.sendInvalid => 'send_invalid',
      PushTokenDeactivationReason.accountDeleted => 'account_deleted',
      PushTokenDeactivationReason.cleanup => 'cleanup',
    };
  }
}
