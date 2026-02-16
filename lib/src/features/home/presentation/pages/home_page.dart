import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';

/// Home page shown after successful authentication.
class HomePage extends StatelessWidget {
  /// Creates the home page.
  const HomePage({super.key});

  /// Builds the page UI.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.homeTitle,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              const SettingsRoute().push<void>(context);
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
