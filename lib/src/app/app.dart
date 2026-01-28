import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/router/app_router.dart';

/// Root widget of the application.
///
/// Responsibilities:
/// - Provide localization configuration
/// - Provide app-level theme configuration
/// - Provide router configuration.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // Localization
      supportedLocales: const <Locale>[Locale('de', 'DE')],
      locale: const Locale('de', 'DE'),
      // Themes
      themeMode: ThemeMode.dark,
    );
  }
}
