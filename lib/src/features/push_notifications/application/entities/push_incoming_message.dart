/// Push message payload normalized for app-level handling.
final class PushIncomingMessage {
  /// Creates a normalized push incoming message.
  const PushIncomingMessage({
    required this.data,
    required this.title,
    required this.body,
    required this.imageUrl,
  });

  /// String-only data payload from FCM.
  final Map<String, String> data;

  /// Notification title when present.
  final String? title;

  /// Notification body when present.
  final String? body;

  /// Optional preview image URL when present.
  final String? imageUrl;
}
