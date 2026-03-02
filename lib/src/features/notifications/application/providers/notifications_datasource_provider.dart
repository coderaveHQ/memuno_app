import 'package:memuno_app/src/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:memuno_app/src/features/notifications/data/datasources/supabase_notifications_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_datasource_provider.g.dart';

/// Provides the notifications datasource implementation.
@Riverpod(keepAlive: true)
NotificationsDatasource notificationsDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseNotificationsDatasourceImpl(supabaseClient: supabaseClient);
}
