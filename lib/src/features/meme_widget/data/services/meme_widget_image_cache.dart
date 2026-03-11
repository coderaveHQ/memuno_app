import 'dart:io';
import 'dart:typed_data';

import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_foundation/path_provider_foundation.dart';

/// Utility for downloading and caching meme images for widget rendering.
///
/// The cached file path is persisted in widget snapshot payloads and consumed by
/// native widget implementations.
final class MemeWidgetImageCache {
  /// Private constructor because this is a static utility.
  const MemeWidgetImageCache._();

  static const String _filePrefix = 'meme_widget_';
  static const String _fileSuffix = '.bin';
  static const String _iosSubdirectory = 'home_widget';

  /// Downloads one image from [url] and returns bytes when successful.
  static Future<Uint8List?> downloadImageBytes(String url) async {
    HttpClient? client;
    try {
      client = HttpClient();
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final BytesBuilder builder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (bytes.isEmpty) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  /// Caches [bytes] for one meme and returns the normalized absolute file path.
  static Future<String?> cacheImageBytes({
    required String memeId,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      return null;
    }

    final Directory? cacheDirectory = await _resolveCacheDirectory();
    if (cacheDirectory == null) {
      return null;
    }

    try {
      await cacheDirectory.create(recursive: true);
      final File file = File(
        '${cacheDirectory.path}/$_filePrefix$memeId$_fileSuffix',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Downloads one image from [imageUrl] and caches it for [memeId].
  static Future<String?> cacheImageFromUrl({
    required String memeId,
    required String imageUrl,
  }) async {
    final Uint8List? bytes = await downloadImageBytes(imageUrl);
    if (bytes == null) {
      return null;
    }
    return cacheImageBytes(memeId: memeId, bytes: bytes);
  }

  /// Returns whether [path] points to an existing local file.
  static Future<bool> isUsablePath(String? path) async {
    final String normalized = normalizePath(path);
    if (normalized.isEmpty) {
      return false;
    }

    try {
      return await File(normalized).exists();
    } catch (_) {
      return false;
    }
  }

  /// Normalizes file URL values (for example `file://...`) into file paths.
  static String normalizePath(String? path) {
    if (path == null) {
      return '';
    }

    final String trimmed = path.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri != null &&
        uri.hasScheme &&
        uri.scheme.toLowerCase() == 'file' &&
        uri.path.isNotEmpty) {
      return uri.toFilePath();
    }

    return trimmed;
  }

  static Future<Directory?> _resolveCacheDirectory() async {
    try {
      if (Platform.isAndroid) {
        return getTemporaryDirectory();
      }

      if (Platform.isIOS) {
        final PathProviderFoundation provider = PathProviderFoundation();
        final String? appGroupContainerPath = await provider.getContainerPath(
          appGroupIdentifier: AppEnv.widgetAppGroupId,
        );

        if (appGroupContainerPath == null ||
            appGroupContainerPath.trim().isEmpty) {
          return null;
        }

        return Directory('$appGroupContainerPath/$_iosSubdirectory');
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
