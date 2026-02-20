import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_templates_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_dto.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_templates_page_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [MemeTemplatesDatasource].
final class SupabaseMemeTemplatesDatasourceImpl
    implements MemeTemplatesDatasource {
  /// Creates the datasource.
  const SupabaseMemeTemplatesDatasourceImpl({
    /// Supabase client used for RPC and storage signing operations.
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Supabase client used for all meme-template calls.
  final SupabaseClient _supabaseClient;

  /// Storage bucket containing private meme-template images.
  static const String _memeTemplatesBucket = 'meme_templates';

  /// Signed URL TTL used for rendering private templates in the picker.
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  /// Loads one page from `meme_templates_list` RPC and signs image URLs.
  Future<MemeTemplatesPageDto> listMemeTemplates({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_templates_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'meme_templates_list',
    );

    final MemeTemplatesPageDto page = MemeTemplatesPageDto.fromJson(json);
    final List<MemeTemplateDto> signedItems = await _attachSignedUrls(
      page.items,
    );

    return page.copyWith(items: signedItems);
  }

  /// Creates signed URLs for every template in [items].
  Future<List<MemeTemplateDto>> _attachSignedUrls(
    List<MemeTemplateDto> items,
  ) async {
    if (items.isEmpty) {
      return items;
    }

    final List<String> imagePaths = items
        .map((MemeTemplateDto item) => item.imagePath)
        .toSet()
        .toList(growable: false);

    final List<dynamic> signedUrls = await _supabaseClient.storage
        .from(_memeTemplatesBucket)
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

    return items
        .map((MemeTemplateDto item) {
          return item.copyWith(signedImageUrl: signedUrlByPath[item.imagePath]);
        })
        .toList(growable: false);
  }

  /// Casts an RPC payload to `Map<String, Object?>`.
  Map<String, Object?> _asObjectMap(
    Object? payload, {
    required String rpcName,
  }) {
    if (payload is! Map) {
      throw FormatException(
        'Expected `$rpcName` to return a JSON object payload.',
      );
    }

    return Map<String, Object?>.from(payload);
  }
}
