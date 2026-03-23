/// Recipient target category returned by meme-details recipient RPCs.
enum MemeRecipientTargetType {
  /// Direct user recipient.
  user('user'),

  /// Group recipient.
  group('group');

  const MemeRecipientTargetType(this.databaseValue);

  /// Raw enum value persisted in Postgres.
  final String databaseValue;

  /// Parses one database value into [MemeRecipientTargetType].
  static MemeRecipientTargetType fromDatabaseValue(String rawValue) {
    return switch (rawValue) {
      'user' => MemeRecipientTargetType.user,
      'group' => MemeRecipientTargetType.group,
      _ => throw FormatException(
        'Unknown meme recipient target type value: $rawValue',
      ),
    };
  }
}
