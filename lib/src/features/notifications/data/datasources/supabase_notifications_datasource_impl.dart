import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_dto.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_data_dto.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [NotificationsDatasource].
final class SupabaseNotificationsDatasourceImpl
    implements NotificationsDatasource {
  /// Creates the datasource.
  const SupabaseNotificationsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;
  static const String _memesBucket = 'memes';
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  /// Loads one page from `notifications_list` RPC.
  Future<NotificationListPageDto> listNotifications({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'notifications_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'notifications_list',
    );

    final NotificationListPageDto page = NotificationListPageDto.fromJson(json);
    return _attachSignedMemeUrls(page);
  }

  @override
  /// Calls `notification_mark_read` for one notification id.
  Future<void> markNotificationRead({required String notificationId}) {
    return _supabaseClient.rpc<void>(
      'notification_mark_read',
      params: <String, dynamic>{'p_notification_id': notificationId},
    );
  }

  @override
  /// Calls `notifications_mark_all_read` and returns affected row count.
  Future<int> markAllNotificationsRead() async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'notifications_mark_all_read',
    );

    if (payload is int) {
      return payload;
    }

    if (payload is num) {
      return payload.toInt();
    }

    throw FormatException(
      'Expected `notifications_mark_all_read` to return an integer payload.',
    );
  }

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

  /// Attaches signed meme image URLs for `meme_received` notifications.
  Future<NotificationListPageDto> _attachSignedMemeUrls(
    NotificationListPageDto page,
  ) async {
    final List<String> memeImagePaths = page.items
        .map((NotificationListPageItemDto item) => item.data)
        .whereType<MemeReceivedNotificationDataDto>()
        .map((MemeReceivedNotificationDataDto item) => item.memeImagePath)
        .toSet()
        .toList(growable: false);

    if (memeImagePaths.isEmpty) {
      return page;
    }

    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      memeImagePaths,
    );
    if (signedUrlByPath.isEmpty) {
      return page;
    }

    final List<NotificationListPageItemDto> signedItems = page.items
        .map((NotificationListPageItemDto item) {
          final NotificationListPageItemDataDto data = item.data;
          if (data is! MemeReceivedNotificationDataDto) {
            return item;
          }

          return NotificationListPageItemDto(
            id: item.id,
            type: item.type,
            data: MemeReceivedNotificationDataDto(
              actorId: data.actorId,
              actorName: data.actorName,
              memeId: data.memeId,
              memeImagePath: data.memeImagePath,
              memeAspectRatio: data.memeAspectRatio,
              signedMemeImageUrl: signedUrlByPath[data.memeImagePath],
              routeTab: data.routeTab,
            ),
            isRead: item.isRead,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          );
        })
        .toList(growable: false);

    return NotificationListPageDto(
      items: signedItems,
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  /// Creates one signed URL map keyed by storage path.
  Future<Map<String, String>> _createSignedUrlMap(List<String> paths) async {
    try {
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
    } catch (_) {
      // Signing failures should not block notification list rendering.
      return const <String, String>{};
    }
  }
}
