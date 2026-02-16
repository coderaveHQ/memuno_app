import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';

/// Page shown after an auth callback (e.g. magic link redirect).
class AuthCallbackPage extends StatelessWidget {
  /// Creates the auth callback page.
  const AuthCallbackPage({super.key});

  /// Builds the page UI.
  @override
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}
