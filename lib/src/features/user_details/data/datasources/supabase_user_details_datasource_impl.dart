import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed user-details datasource.
final class SupabaseUserDetailsDatasourceImpl implements UserDetailsDatasource {
  /// Creates the datasource.
  const SupabaseUserDetailsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  /// Storage bucket containing original meme images.
  static const String _memesBucket = 'memes';

  /// Signed URL TTL used for rendering private meme images.
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  /// Loads one user's details row through RPC.
  Future<UserDetailsDto> getUserDetails({required String userId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'get_users_profile',
      params: <String, dynamic>{'p_user_id': userId},
    );
    if (payload is! Map) {
      throw const FormatException(
        'Expected `get_users_profile` to return an object payload.',
      );
    }

    return UserDetailsDto.fromJson(Map<String, Object?>.from(payload));
  }

  @override
  /// Updates the current user's name via RPC.
  Future<void> updateCurrentUserDetailsName({required String name}) async {
    await _supabaseClient.rpc<void>(
      'update_current_user_name',
      params: <String, dynamic>{'p_name': name},
    );
  }

  @override
  /// Loads one page from `user_details_memes_own_all_list` RPC.
  Future<UserDetailsOwnAllMemesListPageDto> listUserDetailsOwnAllMemes({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_own_all_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_own_all_list',
    );

    final UserDetailsOwnAllMemesListPageDto page =
        UserDetailsOwnAllMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOwnAllPage(page);
  }

  @override
  /// Loads one page from `user_details_memes_own_sent_list` RPC.
  Future<UserDetailsOwnSentMemesListPageDto> listUserDetailsOwnSentMemes({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_own_sent_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_own_sent_list',
    );

    final UserDetailsOwnSentMemesListPageDto page =
        UserDetailsOwnSentMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOwnSentPage(page);
  }

  @override
  /// Loads one page from `user_details_memes_own_received_list` RPC.
  Future<UserDetailsOwnReceivedMemesListPageDto>
  listUserDetailsOwnReceivedMemes({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_own_received_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_own_received_list',
    );

    final UserDetailsOwnReceivedMemesListPageDto page =
        UserDetailsOwnReceivedMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOwnReceivedPage(page);
  }

  @override
  /// Loads one page from `user_details_memes_other_all_list` RPC.
  Future<UserDetailsOtherAllMemesListPageDto> listUserDetailsOtherAllMemes({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_other_all_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_other_all_list',
    );

    final UserDetailsOtherAllMemesListPageDto page =
        UserDetailsOtherAllMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOtherAllPage(page);
  }

  @override
  /// Loads one page from `user_details_memes_other_sent_list` RPC.
  Future<UserDetailsOtherSentMemesListPageDto> listUserDetailsOtherSentMemes({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_other_sent_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_other_sent_list',
    );

    final UserDetailsOtherSentMemesListPageDto page =
        UserDetailsOtherSentMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOtherSentPage(page);
  }

  @override
  /// Loads one page from `user_details_memes_other_received_list` RPC.
  Future<UserDetailsOtherReceivedMemesListPageDto>
  listUserDetailsOtherReceivedMemes({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'user_details_memes_other_received_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'user_details_memes_other_received_list',
    );

    final UserDetailsOtherReceivedMemesListPageDto page =
        UserDetailsOtherReceivedMemesListPageDto.fromJson(json);
    return _attachSignedUrlsToOtherReceivedPage(page);
  }

  @override
  /// Calls `meme_laugh_toggle` and returns the resulting liked-state.
  Future<bool> toggleUserDetailsMemeLaugh({required String memeId}) async {
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

  /// Creates signed URLs for the provided image [paths].
  Future<Map<String, String>> _createSignedUrlMap(List<String> paths) async {
    if (paths.isEmpty) {
      return const <String, String>{};
    }

    final List<dynamic> signedUrls = await _supabaseClient.storage
        .from(_memesBucket)
        .createSignedUrls(paths, _signedUrlExpiresInSeconds);

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

  /// Adds signed URLs to every own-all memes page item.
  Future<UserDetailsOwnAllMemesListPageDto> _attachSignedUrlsToOwnAllPage(
    UserDetailsOwnAllMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOwnAllMemesListPageItemDto item) => item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOwnAllMemesListPageItemDto> signedItems = page.items
        .map((UserDetailsOwnAllMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }

  /// Adds signed URLs to every own-sent memes page item.
  Future<UserDetailsOwnSentMemesListPageDto> _attachSignedUrlsToOwnSentPage(
    UserDetailsOwnSentMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOwnSentMemesListPageItemDto item) =>
                item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOwnSentMemesListPageItemDto> signedItems = page.items
        .map((UserDetailsOwnSentMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }

  /// Adds signed URLs to every own-received memes page item.
  Future<UserDetailsOwnReceivedMemesListPageDto>
  _attachSignedUrlsToOwnReceivedPage(
    UserDetailsOwnReceivedMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOwnReceivedMemesListPageItemDto item) =>
                item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOwnReceivedMemesListPageItemDto> signedItems = page
        .items
        .map((UserDetailsOwnReceivedMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }

  /// Adds signed URLs to every other-all memes page item.
  Future<UserDetailsOtherAllMemesListPageDto> _attachSignedUrlsToOtherAllPage(
    UserDetailsOtherAllMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOtherAllMemesListPageItemDto item) =>
                item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOtherAllMemesListPageItemDto> signedItems = page.items
        .map((UserDetailsOtherAllMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }

  /// Adds signed URLs to every other-sent memes page item.
  Future<UserDetailsOtherSentMemesListPageDto> _attachSignedUrlsToOtherSentPage(
    UserDetailsOtherSentMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOtherSentMemesListPageItemDto item) =>
                item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOtherSentMemesListPageItemDto> signedItems = page
        .items
        .map((UserDetailsOtherSentMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }

  /// Adds signed URLs to every other-received memes page item.
  Future<UserDetailsOtherReceivedMemesListPageDto>
  _attachSignedUrlsToOtherReceivedPage(
    UserDetailsOtherReceivedMemesListPageDto page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map(
            (UserDetailsOtherReceivedMemesListPageItemDto item) =>
                item.meme.imagePath,
          )
          .toSet()
          .toList(growable: false),
    );

    final List<UserDetailsOtherReceivedMemesListPageItemDto> signedItems = page
        .items
        .map((UserDetailsOtherReceivedMemesListPageItemDto item) {
          return item.copyWith(
            meme: item.meme.copyWith(
              signedImageUrl: signedUrlByPath[item.meme.imagePath],
            ),
          );
        })
        .toList(growable: false);

    return page.copyWith(items: signedItems);
  }
}
