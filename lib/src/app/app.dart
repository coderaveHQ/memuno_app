import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/app_effects.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/app/settings/theme_resolution_provider.dart';
import 'package:memuno_app/src/app/theme/app_theme.dart' as app_theme;
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/infrastructure/platform/system_brightness_provider.dart';
import 'package:memuno_app/src/infrastructure/platform/system_locale_provider.dart';

/// Root widget of the application.
///
/// Responsibilities:
/// - Provide localization configuration
/// - Provide app-level theme configuration
/// - Provide router configuration.
class App extends ConsumerStatefulWidget {
  /// Creates the root app widget.
  const App({super.key});

  @override
  /// Creates the state object for this widget.
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  /// Clears focus from the currently focused input field.
  void _unfocusKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  /// Initializes state when the widget is inserted into the tree.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  /// Releases resources held by this instance.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  /// Handles platform brightness updates from the operating system.
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(systemBrightnessProvider.notifier).update(brightness);
    super.didChangePlatformBrightness();
  }

  @override
  /// Handles locale updates from the operating system.
  void didChangeLocales(List<Locale>? locales) {
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    ref.read(systemLocaleProvider.notifier).update(locale);
    super.didChangeLocales(locales);
  }

  /// Builds the root widget tree and configures routing, localization, and theming.
  @override
  Widget build(BuildContext context) {
    // Watch the router provider so navigation stays reactive.
    final GoRouter router = ref.watch(appRouterProvider);

    // Watch localization + theme resolution.
    final LanguageResolution languageResolution = ref.watch(
      languageResolutionProvider,
    );
    final ThemeResolution themeResolution = ref.watch(themeResolutionProvider);
    final ThemeMode themeMode = switch (themeResolution.preference) {
      AppTheme.system => ThemeMode.system,
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
    };

    return GestureDetector(
      onTap: _unfocusKeyboard,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        // Localization
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: languageResolution.resolvedLocale,
        // Themes
        theme: app_theme.AppTheme.light(),
        darkTheme: app_theme.AppTheme.dark(),
        themeMode: themeMode,
        builder: (BuildContext context, Widget? child) {
          final Widget safeChild = child ?? const SizedBox.shrink();
          return AppEffects(child: safeChild);
        },
      ),
    );
  }
}
