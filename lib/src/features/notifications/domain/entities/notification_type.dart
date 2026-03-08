/// Domain enum for notification categories persisted in the database.
enum NotificationType {
  /// A user sent a friendship request to the recipient.
  friendshipRequestSent('friendship_request_sent'),

  /// A recipient accepted a previously sent friendship request.
  friendshipRequestAccepted('friendship_request_accepted'),

  /// A friend sent a meme to the recipient.
  memeReceived('meme_received'),

  /// A user laughed at one of the recipient's memes.
  memeLaughed('meme_laughed');

  const NotificationType(this.databaseValue);

  /// Raw enum value persisted in Postgres.
  final String databaseValue;

  /// Parses one database enum value into a domain [NotificationType].
  static NotificationType fromDatabaseValue(String rawValue) {
    return switch (rawValue) {
      'friendship_request_sent' => NotificationType.friendshipRequestSent,
      'friendship_request_accepted' =>
        NotificationType.friendshipRequestAccepted,
      'meme_received' => NotificationType.memeReceived,
      'meme_laughed' => NotificationType.memeLaughed,
      _ => throw FormatException('Unknown notification type value: $rawValue'),
    };
  }
}
