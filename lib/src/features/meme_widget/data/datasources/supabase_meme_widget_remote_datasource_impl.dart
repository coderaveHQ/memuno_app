import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_remote_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [MemeWidgetRemoteDatasource].
final class SupabaseMemeWidgetRemoteDatasourceImpl
    implements MemeWidgetRemoteDatasource {
  /// Creates the datasource.
  const SupabaseMemeWidgetRemoteDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const String _memesBucket = 'memes';
  static const int _signedUrlExpiresInSeconds = 7 * 24 * 60 * 60;

  /// Default background color (`MColors.gray900`).
  static const String _defaultBackgroundHex = '#191919';

  /// Default foreground color (`MColors.gray100`).
  static const String _defaultForegroundHex = '#FBFBFB';

  @override
  Future<List<MemeWidgetItemEntity>> loadLatestItems({
    required int limit,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'feed_list',
      params: <String, Object?>{
        'p_limit': limit,
        'p_cursor_created_at': null,
        'p_cursor_id': null,
      },
    );

    final Map<String, Object?> json = _asObjectMap(payload);
    final List<Map<String, Object?>> items = _asObjectList(json['items']);

    final List<String> imagePaths = items
        .map((Map<String, Object?> item) => _asObjectMap(item['meme']))
        .map((Map<String, Object?> meme) => _readString(meme, 'image_path'))
        .toSet()
        .toList(growable: false);

    final Map<String, String> signedUrlsByPath = await _createSignedUrlMap(
      imagePaths,
    );

    final String? currentUserId = _supabaseClient.auth.currentUser?.id;

    final List<MemeWidgetItemEntity> parsedItems = <MemeWidgetItemEntity>[];
    for (final Map<String, Object?> item in items) {
      final Map<String, Object?> meme = _asObjectMap(item['meme']);
      final Map<String, Object?> user = _asObjectMap(item['user']);

      final String imagePath = _readString(meme, 'image_path');
      final String? signedUrl = signedUrlsByPath[imagePath];
      if (signedUrl == null || signedUrl.isEmpty) {
        continue;
      }

      final String creatorId = _readString(user, 'id');
      final double aspectRatio = _readPositiveDouble(meme, 'aspect_ratio');

      parsedItems.add(
        MemeWidgetItemEntity(
          memeId: _readString(meme, 'id'),
          creatorId: creatorId,
          creatorName: _readString(user, 'name'),
          laughCount: _readNonNegativeInt(meme, 'laugh_count'),
          isLaughed: _readBool(meme, 'is_laughed'),
          isOwnMeme: currentUserId != null && currentUserId == creatorId,
          aspectRatio: aspectRatio,
          imagePath: imagePath,
          imageUrlFull: signedUrl,
          androidCachedImagePath: null,
          backgroundHex: _defaultBackgroundHex,
          foregroundHex: _defaultForegroundHex,
        ),
      );
    }

    return List<MemeWidgetItemEntity>.unmodifiable(parsedItems);
  }

  @override
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_laugh_toggle',
      params: <String, Object?>{'p_meme_id': memeId},
    );

    if (payload is bool) {
      return payload;
    }

    if (payload is num) {
      return payload != 0;
    }

    throw const FormatException(
      'Expected `meme_laugh_toggle` to return a boolean payload.',
    );
  }

  Future<Map<String, String>> _createSignedUrlMap(
    List<String> imagePaths,
  ) async {
    if (imagePaths.isEmpty) {
      return const <String, String>{};
    }

    final List<dynamic> signedUrls = await _supabaseClient.storage
        .from(_memesBucket)
        .createSignedUrls(imagePaths, _signedUrlExpiresInSeconds);

    final Map<String, String> signedUrlByPath = <String, String>{};
    for (final dynamic signedUrl in signedUrls) {
      final Object? path = signedUrl.path;
      final Object? url = signedUrl.signedUrl;
      if (path is String &&
          path.isNotEmpty &&
          url is String &&
          url.isNotEmpty) {
        signedUrlByPath[path] = url;
      }
    }

    return signedUrlByPath;
  }

  Map<String, Object?> _asObjectMap(Object? payload) {
    if (payload is! Map) {
      throw const FormatException('Expected object payload.');
    }

    return Map<String, Object?>.from(payload);
  }

  List<Map<String, Object?>> _asObjectList(Object? payload) {
    if (payload is! List) {
      return const <Map<String, Object?>>[];
    }

    return payload
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> value) => Map<String, Object?>.from(value))
        .toList(growable: false);
  }

  String _readString(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected non-empty string field `$key`.');
    }

    return value;
  }

  bool _readBool(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is! bool) {
      throw FormatException('Expected boolean field `$key`.');
    }

    return value;
  }

  int _readNonNegativeInt(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is! num) {
      throw FormatException('Expected numeric field `$key`.');
    }

    final int parsed = value.toInt();
    if (parsed < 0) {
      throw FormatException('Expected non-negative field `$key`.');
    }

    return parsed;
  }

  double _readPositiveDouble(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is! num) {
      throw FormatException('Expected numeric field `$key`.');
    }

    final double parsed = value.toDouble();
    if (parsed <= 0) {
      throw FormatException('Expected positive field `$key`.');
    }

    return parsed;
  }
}
