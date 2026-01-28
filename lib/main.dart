import 'package:memuno_app/src/app/bootstrap/bootstrap.dart';

/// App entry point.
///
/// We keep `main()` extremely small:
/// - All bootstrapping (Firebase/Supabase, error handlers, etc.) is done in
///   [bootstrap] to keep startup logic centralized and testable.
Future<void> main() async {
  await bootstrap();
}
