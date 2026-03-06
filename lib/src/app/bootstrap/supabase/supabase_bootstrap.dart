import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase.
///
/// We rely on `--dart-define` values (see [AppEnv]).
/// In debug, [AppEnv] asserts the values are present.
Future<void> bootstrapSupabase() async {
  await Supabase.initialize(
    url: AppEnv.secrets.supabaseUrl,
    anonKey: AppEnv.secrets.supabasePublishableKey,
  );
}
