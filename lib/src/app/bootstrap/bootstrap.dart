import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/app.dart';
import 'package:memuno_app/src/app/bootstrap/firebase/firebase_bootstrap.dart';
import 'package:memuno_app/src/app/bootstrap/supabase/supabase_bootstrap.dart';
import 'package:memuno_app/src/core/utils/logger.dart';

/// Centralized app bootstrap.
///
/// Responsibilities:
/// - Initialize Flutter binding.
/// - Register global error handlers (Flutter framework + platform dispatcher).
/// - Initialize Supabase and Firebase.
/// - Start the app with Riverpod [ProviderScope].
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      // Ensure Flutter engine is initialized.
      final WidgetsBinding _ = WidgetsFlutterBinding.ensureInitialized();

      // -----------------------------------------------------------------------
      // Global error handling (pre-runApp)
      // -----------------------------------------------------------------------

      FlutterError.onError = (final FlutterErrorDetails details) async {
        // Print error to console in debug.
        FlutterError.presentError(details);

        // Report to Crashlytics in release/profile mode.
        if (!kDebugMode) {
          await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      PlatformDispatcher.instance.onError =
          (final Object error, final StackTrace stackTrace) {
            // In debug we still want to see it.
            Logger.instance.error(
              message: 'Uncaught platform dispatcher error',
              error: error,
              stackTrace: stackTrace,
            );

            // Report to Crashlytics outside debug.
            if (!kDebugMode) {
              FirebaseCrashlytics.instance.recordError(
                error,
                stackTrace,
                fatal: true,
              );
            }

            // Returning `true` tells Flutter "we handled it".
            return true;
          };

      // -----------------------------------------------------------------------
      // Backend initialization
      // -----------------------------------------------------------------------

      await bootstrapSupabase();
      await bootstrapFirebase();

      // Start the app with Riverpod.
      runApp(const ProviderScope(child: App()));
    },
    (final Object error, final StackTrace stackTrace) async {
      // A last-resort catch for anything escaping the guarded zone.
      Logger.instance.error(
        message: 'Uncaught zoned error during bootstrap',
        error: error,
        stackTrace: stackTrace,
      );

      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        );
      }
    },
  );
}
