import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
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
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_own_all_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOwnAllPageDto(signedPage);
  }

  @override
  /// Loads one page from `user_details_memes_own_sent_list` RPC.
  Future<UserDetailsOwnSentMemesListPageDto> listUserDetailsOwnSentMemes({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_own_sent_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOwnSentPageDto(signedPage);
  }

  @override
  /// Loads one page from `user_details_memes_own_received_list` RPC.
  Future<UserDetailsOwnReceivedMemesListPageDto>
  listUserDetailsOwnReceivedMemes({
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_own_received_list',
      params: <String, dynamic>{
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOwnReceivedPageDto(signedPage);
  }

  @override
  /// Loads one page from `user_details_memes_other_all_list` RPC.
  Future<UserDetailsOtherAllMemesListPageDto> listUserDetailsOtherAllMemes({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_other_all_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOtherAllPageDto(signedPage);
  }

  @override
  /// Loads one page from `user_details_memes_other_sent_list` RPC.
  Future<UserDetailsOtherSentMemesListPageDto> listUserDetailsOtherSentMemes({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_other_sent_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOtherSentPageDto(signedPage);
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
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'user_details_memes_other_received_list',
      params: <String, dynamic>{
        'p_user_id': userId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    final ListPageDto<MemeItemDto> signedPage =
        await _attachSignedUrlsToMemeItemPage(page);
    return _toOtherReceivedPageDto(signedPage);
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

  Future<ListPageDto<MemeItemDto>> _listMemeItemPage({
    required String rpcName,
    required Map<String, dynamic> params,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      rpcName,
      params: params,
    );
    final Map<String, Object?> json = _asObjectMap(payload, rpcName: rpcName);
    return ListPageDto<MemeItemDto>.fromJson(
      json,
      itemFromJson: MemeItemDto.fromJson,
    );
  }

  /// Adds signed URLs to canonical meme-item page items.
  Future<ListPageDto<MemeItemDto>> _attachSignedUrlsToMemeItemPage(
    ListPageDto<MemeItemDto> page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map((MemeItemDto item) => item.imagePath)
          .toSet()
          .toList(growable: false),
    );

    final List<MemeItemDto> signedItems = page.items
        .map((MemeItemDto item) {
          return item.copyWith(signedImageUrl: signedUrlByPath[item.imagePath]);
        })
        .toList(growable: false);

    return ListPageDto<MemeItemDto>(
      items: signedItems,
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOwnAllMemesListPageDto _toOwnAllPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOwnAllMemesListPageDto(
      items: page.items.map(_toOwnAllItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOwnSentMemesListPageDto _toOwnSentPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOwnSentMemesListPageDto(
      items: page.items.map(_toOwnSentItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOwnReceivedMemesListPageDto _toOwnReceivedPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOwnReceivedMemesListPageDto(
      items: page.items.map(_toOwnReceivedItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOtherAllMemesListPageDto _toOtherAllPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOtherAllMemesListPageDto(
      items: page.items.map(_toOtherAllItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOtherSentMemesListPageDto _toOtherSentPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOtherSentMemesListPageDto(
      items: page.items.map(_toOtherSentItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOtherReceivedMemesListPageDto _toOtherReceivedPageDto(
    ListPageDto<MemeItemDto> page,
  ) {
    return UserDetailsOtherReceivedMemesListPageDto(
      items: page.items.map(_toOtherReceivedItemDto).toList(growable: false),
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  UserDetailsOwnAllMemesListPageItemDto _toOwnAllItemDto(MemeItemDto item) {
    final UserDetailsOwnAllMemesListPageItemDto parsed =
        UserDetailsOwnAllMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  UserDetailsOwnSentMemesListPageItemDto _toOwnSentItemDto(MemeItemDto item) {
    final UserDetailsOwnSentMemesListPageItemDto parsed =
        UserDetailsOwnSentMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  UserDetailsOwnReceivedMemesListPageItemDto _toOwnReceivedItemDto(
    MemeItemDto item,
  ) {
    final UserDetailsOwnReceivedMemesListPageItemDto parsed =
        UserDetailsOwnReceivedMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  UserDetailsOtherAllMemesListPageItemDto _toOtherAllItemDto(MemeItemDto item) {
    final UserDetailsOtherAllMemesListPageItemDto parsed =
        UserDetailsOtherAllMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  UserDetailsOtherSentMemesListPageItemDto _toOtherSentItemDto(
    MemeItemDto item,
  ) {
    final UserDetailsOtherSentMemesListPageItemDto parsed =
        UserDetailsOtherSentMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  UserDetailsOtherReceivedMemesListPageItemDto _toOtherReceivedItemDto(
    MemeItemDto item,
  ) {
    final UserDetailsOtherReceivedMemesListPageItemDto parsed =
        UserDetailsOtherReceivedMemesListPageItemDto.fromJson(
          _legacyMemeItemJson(item),
        );
    return parsed.copyWith(
      meme: parsed.meme.copyWith(signedImageUrl: item.signedImageUrl),
    );
  }

  Map<String, Object?> _legacyMemeItemJson(MemeItemDto item) {
    return <String, Object?>{
      'meme': <String, Object?>{
        'id': item.id,
        'created_at': item.createdAt.toIso8601String(),
        'updated_at': item.updatedAt.toIso8601String(),
        'image_path': item.imagePath,
        'aspect_ratio': item.aspectRatio,
        'laugh_count': item.laughCount,
        'is_laughed': item.isLaughed,
      },
      'user': <String, Object?>{
        'id': item.user.id,
        'name': item.user.name,
        'friendship_code': item.user.friendshipCode,
        'created_at': item.user.createdAt.toIso8601String(),
        'updated_at': item.user.updatedAt.toIso8601String(),
      },
    };
  }
}
