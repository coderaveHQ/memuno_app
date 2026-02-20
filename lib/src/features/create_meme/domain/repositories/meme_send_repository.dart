import 'dart:typed_data';

/// Repository contract for sending finalized memes.
abstract class MemeSendRepository {
  /// Uploads and stores one finalized meme with selected recipients.
  Future<void> sendMeme({
    /// Finalized PNG bytes rendered from meme editor.
    required Uint8List memeBytes,

    /// Template identifier selected in editor.
    required String templateId,

    /// Target recipient user identifiers.
    required List<String> recipientUserIds,
  });
}
