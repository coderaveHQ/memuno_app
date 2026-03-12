import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_render_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';

/// Local datasource implementation for meme render-size and byte normalization.
final class LocalMemeEditorRenderDatasourceImpl
    implements MemeEditorRenderDatasource {
  /// Creates the datasource.
  const LocalMemeEditorRenderDatasourceImpl();

  @override
  /// Resolves source background size from custom image bytes or template URL.
  Future<MemeImageSizeEntity> resolveBackgroundSize({
    required MemeEditorStateEntity state,
  }) async {
    final Uint8List? customImageBytes = state.customTemplateImageBytes;
    if (customImageBytes != null && customImageBytes.isNotEmpty) {
      return _decodeImageSize(customImageBytes);
    }

    final String? signedImageUrl = state.template?.signedImageUrl;
    if (signedImageUrl == null || signedImageUrl.trim().isEmpty) {
      throw StateError('No meme background is selected.');
    }

    final Uint8List downloadedBytes = await _downloadBytes(signedImageUrl);
    return _decodeImageSize(downloadedBytes);
  }

  @override
  /// Normalizes captured PNG bytes to exact [targetSize] pixels.
  Uint8List normalizeFinalizedImageBytes({
    required Uint8List bytes,
    required MemeImageSizeEntity targetSize,
  }) {
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw StateError('Unable to decode captured meme bytes.');
    }

    if (decodedImage.width == targetSize.width &&
        decodedImage.height == targetSize.height) {
      return bytes;
    }

    final img.Image resized = img.copyResize(
      decodedImage,
      width: targetSize.width,
      height: targetSize.height,
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodePng(resized));
  }

  /// Downloads one image payload from [url].
  Future<Uint8List> _downloadBytes(String url) async {
    HttpClient? client;
    try {
      client = HttpClient();
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Failed to load template image. (${response.statusCode})',
        );
      }

      final BytesBuilder builder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        builder.add(chunk);
      }

      final Uint8List bytes = builder.takeBytes();
      if (bytes.isEmpty) {
        throw StateError('Template image response is empty.');
      }

      return bytes;
    } finally {
      client?.close(force: true);
    }
  }

  /// Decodes one image payload and returns its pixel dimensions.
  MemeImageSizeEntity _decodeImageSize(Uint8List bytes) {
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw StateError('Unable to decode meme background image.');
    }

    return MemeImageSizeEntity(
      width: decodedImage.width,
      height: decodedImage.height,
    );
  }
}
