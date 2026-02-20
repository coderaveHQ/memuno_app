import 'dart:typed_data';

/// Datasource contract for remote meme-send operations.
abstract class MemeSendDatasource {
  /// Uploads meme bytes and creates one meme with recipients through RPC.
  Future<void> sendMeme({
    /// Finalized PNG bytes rendered in meme editor.
    required Uint8List memeBytes,

    /// Template identifier selected in editor.
    required String templateId,

    /// Target recipient user identifiers.
    required List<String> recipientUserIds,
  });
}
