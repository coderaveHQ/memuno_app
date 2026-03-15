import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/feed/data/datasources/feed_datasource.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_user_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [FeedDatasource].
final class SupabaseFeedDatasourceImpl implements FeedDatasource {
  /// Creates the datasource.
  const SupabaseFeedDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  /// Supabase client used for RPC and storage signing operations.
  final SupabaseClient _supabaseClient;

  /// Storage bucket containing original meme images.
  static const String _memesBucket = 'memes';

  /// Signed URL TTL used for rendering private meme images.
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  /// Loads one page from `feed_list` RPC and signs image URLs.
  Future<FeedListPageDto> listFeed({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'feed_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'feed_list',
    );

    final ListPageDto<MemeItemDto> page = ListPageDto<MemeItemDto>.fromJson(
      json,
      itemFromJson: MemeItemDto.fromJson,
    );
    final List<MemeItemDto> signedItems = await _attachSignedUrls(page.items);
    return FeedListPageDto(
      items: signedItems.map(_toFeedListPageItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
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

  /// Creates signed URLs for every feed item image in [items].
  Future<List<MemeItemDto>> _attachSignedUrls(List<MemeItemDto> items) async {
    if (items.isEmpty) {
      return items;
    }

    final List<String> imagePaths = items
        .map((MemeItemDto item) => item.imagePath)
        .toSet()
        .toList(growable: false);

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

    return items
        .map((MemeItemDto item) {
          return item.copyWith(signedImageUrl: signedUrlByPath[item.imagePath]);
        })
        .toList(growable: false);
  }

  FeedListPageItemDto _toFeedListPageItemDto(MemeItemDto item) {
    return FeedListPageItemDto(
      meme: FeedListPageItemMemeDto(
        id: item.id,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        imagePath: item.imagePath,
        aspectRatio: item.aspectRatio,
        laughCount: item.laughCount,
        isLaughed: item.isLaughed,
        signedImageUrl: item.signedImageUrl,
      ),
      user: FeedListPageItemUserDto(
        id: item.user.id,
        name: item.user.name,
        friendshipCode: item.user.friendshipCode,
        createdAt: item.user.createdAt,
        updatedAt: item.user.updatedAt,
      ),
    );
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
