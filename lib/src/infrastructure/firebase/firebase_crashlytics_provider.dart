import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_crashlytics_provider.g.dart';

/// Riverpod provider for [FirebaseCrashlytics].
@Riverpod(keepAlive: true)
FirebaseCrashlytics firebaseCrashlytics(Ref ref) {
  // Return the singleton Crashlytics instance.
  return FirebaseCrashlytics.instance;
}
