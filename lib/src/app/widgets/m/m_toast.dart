import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:zentoast/zentoast.dart';

enum MToastVariant {
  success(
    backgroundColor: MColors.green400,
    foregroundColor: MColors.white,
    icon: LucideIcons.check,
  ),
  info(
    backgroundColor: MColors.blue400,
    foregroundColor: MColors.white,
    icon: LucideIcons.info,
  ),
  warning(
    backgroundColor: MColors.orange400,
    foregroundColor: MColors.white,
    icon: LucideIcons.triangle_alert,
  ),
  error(
    backgroundColor: MColors.red400,
    foregroundColor: MColors.white,
    icon: LucideIcons.skull,
  );

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const MToastVariant({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

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
  Toast(
    category: ToastCategory.success,
    builder: (toast) => MToast(
      variant: variant,
      title: variant.title(context),
      message: message,
      height: toast.height,
      onClose: () => toast.hide(context),
    ),
  ).show(context);
}

class MToast extends StatelessWidget {
  const MToast({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.height,
    required this.onClose,
  });

  final MToastVariant variant;
  final String title;
  final String message;
  final double height;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          horizontal: MSpacing.sm,
          vertical: MSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: variant.backgroundColor,
          border: Border.all(color: Colors.black, width: 3.0),
          borderRadius: BorderRadius.zero,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              offset: Offset(4.0, 4.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28.0,
              height: 28.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: Icon(variant.icon, size: 18.0, color: Colors.black),
            ),
            const MGap.sm(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MText.p(
                    text: title.toUpperCase(),
                    style: TextStyle(
                      color: variant.foregroundColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const MGap.xxs(),
                  MText.small(
                    text: message,
                    style: TextStyle(
                      color: variant.foregroundColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const MGap.sm(),
            InkWell(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MSpacing.sm,
                  vertical: MSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: MText(
                  text: 'X',
                  style: TextStyle(
                    color: variant.foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
