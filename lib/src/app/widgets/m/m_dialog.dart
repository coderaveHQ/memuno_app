import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

Future<T?> showMDialog<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
}) async {
  return await showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: builder,
  );
}

class MDialog extends StatelessWidget {
  final String? title;
  final Widget? child;
  const MDialog({super.key, this.title, this.child});

  void _onClose(BuildContext context) {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20.0),
      ),
      insetPadding: EdgeInsets.all(MSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(MSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MText.h4(
                      text: title,
                      style: TextStyle(color: MColors.gray100),
                    ),
                  ),
                ),
                const MGap.md(),
                MIconButton.secondary(
                  onPressed: () => _onClose(context),
                  dimension: 48.0,
                  icon: LucideIcons.x,
                ),
              ],
            ),
            if (child != null)
              Padding(
                padding: EdgeInsets.only(top: MSpacing.md),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}
