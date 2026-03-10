import 'dart:async';

import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_unread_count_provider.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_realtime_sync_provider.g.dart';

/// App-global realtime sync for unread notification count invalidation.
@Riverpod(keepAlive: true)
void notificationsRealtimeSync(Ref ref) {
  final String? currentUserId = ref.watch(currentUserProvider)?.id;

  ref.invalidate(notificationsUnreadCountProvider);

  if (currentUserId == null) {
    return;
  }

  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  final Logger logger = ref.watch(loggerProvider);

  final RealtimeChannel channel = supabaseClient
      .channel('public:notifications:recipient:$currentUserId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'recipient_id',
          value: currentUserId,
        ),
        callback: (PostgresChangePayload payload) {
          ref.invalidate(notificationsUnreadCountProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'recipient_id',
          value: currentUserId,
        ),
        callback: (PostgresChangePayload payload) {
          ref.invalidate(notificationsUnreadCountProvider);
        },
      )
      .subscribe();

  ref.onDispose(() {
    unawaited(supabaseClient.removeChannel(channel));
    logger.info(
      message: 'Disposed notifications realtime channel for $currentUserId.',
    );
  });
}
