import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/app.dart';
import 'package:memuno_app/src/app/bootstrap/firebase/firebase_bootstrap.dart';
import 'package:memuno_app/src/app/bootstrap/supabase/supabase_bootstrap.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/infrastructure/shared_preferences/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      // Start the app with Riverpod.
      runApp(
        ProviderScope(
          overrides: <Override>[
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const App(),
        ),
      );
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
