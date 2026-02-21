import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/app_effects.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_theme.dart';
import 'package:memuno_app/src/infrastructure/platform/system_locale_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zentoast/zentoast.dart';

/// Root widget of the application.
///
/// Responsibilities:
/// - Provide localization configuration
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

    // Watch localization resolution.
    final LanguageResolution languageResolution = ref.watch(
      languageResolutionProvider,
    );

    return GestureDetector(
      onTap: _unfocusKeyboard,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        // Localization
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: languageResolution.resolvedLocale,
        builder: (BuildContext context, Widget? child) {
          return SkeletonizerConfig(
            data: MTheme.sekeltonizerDarkData,
            child: ToastThemeProvider(
              data: ToastTheme(
                gap: MSpacing.xs,
                viewerPadding: EdgeInsets.all(MSpacing.sm),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppEffects(child: child ?? const SizedBox.shrink()),
                  ),
                  SafeArea(
                    child: ToastViewer(
                      alignment: Alignment.topRight,
                      delay: Duration(seconds: 3),
                      visibleCount: 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
