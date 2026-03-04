import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [NotificationsDatasource].
final class SupabaseNotificationsDatasourceImpl
    implements NotificationsDatasource {
  /// Creates the datasource.
  const SupabaseNotificationsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

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

    return NotificationListPageDto.fromJson(json);
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
}
