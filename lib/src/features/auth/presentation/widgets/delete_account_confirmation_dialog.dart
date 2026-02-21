import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_dialog.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

Future<bool?> showDeleteAccountConfirmationDialog(BuildContext context) async {
  return await showMDialog<bool>(
    context,
    builder: (BuildContext _) => const DeleteAccountConfirmationDialog(),
  );
}

class DeleteAccountConfirmationDialog extends StatelessWidget {
  const DeleteAccountConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MDialog(
      title: l10n.deleteAccountConfirmTitle,
      child: Column(
        children: <Widget>[
          MText.p(
            text: l10n.deleteAccountConfirmMessage,
            style: TextStyle(color: MColors.gray100),
          ),
          const MGap.md(),
          MButton.destructive(
            onPressed: () => context.pop(true),
            title: l10n.deleteAccountConfirmDeleteButton,
          ),
          const MGap.md(),
          MButton.secondary(
            onPressed: () => context.pop(false),
            title: l10n.deleteAccountConfirmCancelButton,
          ),
        ],
      ),
    );
  }
}
