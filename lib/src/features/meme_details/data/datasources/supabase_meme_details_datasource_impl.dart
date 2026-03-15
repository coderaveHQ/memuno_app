import 'package:memuno_app/src/features/meme_details/data/datasources/meme_details_datasource.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [MemeDetailsDatasource].
final class SupabaseMemeDetailsDatasourceImpl implements MemeDetailsDatasource {
  /// Creates the datasource.
  const SupabaseMemeDetailsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const String _memesBucket = 'memes';
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  /// Loads one meme details payload from `meme_details_get` RPC.
  Future<MemeDetailsDto> getMemeDetails({required String memeId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_details_get',
      params: <String, dynamic>{'p_meme_id': memeId},
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'meme_details_get',
    );

    final MemeDetailsDto details = MemeDetailsDto.fromJson(json);
    final String signedImageUrl = await _createSignedImageUrl(
      details.imagePath,
    );

    return details.copyWith(signedImageUrl: signedImageUrl);
  }

  @override
  /// Loads one page of laughed users from `meme_laughs_list` RPC.
  Future<MemeLaughListPageDto> listMemeLaughs({
    required String memeId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_laughs_list',
      params: <String, dynamic>{
        'p_meme_id': memeId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'meme_laughs_list',
    );

    return MemeLaughListPageDto.fromJson(json);
  }

  @override
  /// Calls `meme_laugh_toggle` and returns the resulting liked-state.
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_laugh_toggle',
      params: <String, dynamic>{'p_meme_id': memeId},
    );

    if (payload is bool) {
      return payload;
    }

    throw const FormatException(
      'Expected `meme_laugh_toggle` to return a boolean payload.',
    );
  }

  /// Casts one RPC payload to `Map<String, Object?>`.
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

  /// Creates one signed URL for the original meme image path.
  Future<String> _createSignedImageUrl(String imagePath) async {
    final List<dynamic> signedUrls = await _supabaseClient.storage
        .from(_memesBucket)
        .createSignedUrls(<String>[imagePath], _signedUrlExpiresInSeconds);

    if (signedUrls.isEmpty) {
      throw const FormatException(
        'Expected `meme_details_get` image signing to return one signed URL.',
      );
    }

    final dynamic signedUrl = signedUrls.first;
    final Object? url = signedUrl.signedUrl;
    if (url is! String || url.isEmpty) {
      throw const FormatException(
        'Expected `meme_details_get` image signing to return a valid URL.',
      );
    }

    return url;
  }
}
