import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';

/// Page shown after an auth callback (e.g. magic link redirect).
class AuthCallbackPage extends StatelessWidget {
  /// Creates the auth callback page.
  const AuthCallbackPage({super.key});

  /// Builds the page UI.
  @override
  Widget build(BuildContext context) {
    return MScaffold(body: MCenter(child: MCircularProgressIndicator()));
  }
}
