import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

enum MToastVariant {
  success(color: MColors.green400, icon: LucideIcons.check),
  info(color: MColors.blue400, icon: LucideIcons.info),
  warning(color: MColors.orange400, icon: LucideIcons.triangle_alert),
  error(color: MColors.red400, icon: LucideIcons.skull);

  final Color color;
  final IconData icon;

  const MToastVariant({required this.color, required this.icon});

  String title(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      MToastVariant.success => l10n.toastTitleSuccess,
      MToastVariant.info => l10n.toastTitleInfo,
      MToastVariant.warning => l10n.toastTitleWarning,
      MToastVariant.error => l10n.toastTitleError,
    };
  }
}

void showMToast(BuildContext context, MToastVariant variant, String message) {
  final String resolvedTitle = variant.title(context);

  DelightToastBar(
    autoDismiss: true,
    builder: (BuildContext _) => ToastCard(
      color: MColors.gray900,
      leading: Icon(variant.icon, size: 32.0, color: variant.color),
      title: MText.h5(
        text: resolvedTitle,
        style: TextStyle(color: MColors.gray100),
      ),
      subtitle: MText.p(
        text: message,
        style: TextStyle(color: MColors.gray100),
      ),
    ),
  ).show(context);
}
