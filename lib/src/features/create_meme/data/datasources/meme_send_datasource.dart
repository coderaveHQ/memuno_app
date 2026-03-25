import 'dart:typed_data';

/// Datasource contract for remote meme-send operations.
abstract class MemeSendDatasource {
  /// Uploads meme bytes and creates one meme with recipients through RPC.
  Future<void> sendMeme({
    /// Finalized PNG bytes rendered in meme editor.
    required Uint8List memeBytes,

    /// Template identifier selected in editor.
    required String templateId,

    /// Aspect ratio (`width / height`) for the uploaded meme image.
    required double aspectRatio,

    /// Target recipient user identifiers.
    required List<String> recipientUserIds,

    /// Target group identifiers.
    required List<String> recipientGroupIds,

    /// Plain-text meme layer values for server-side validation.
    required List<String> textLayers,
  });
}
