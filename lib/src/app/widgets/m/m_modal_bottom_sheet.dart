import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

Future<T?> showMModalBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = false,
}) async {
  return await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: MColors.gray900,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: builder,
  );
}

class MModalBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? child;

  const MModalBottomSheet({super.key, this.title, this.child});

  void _onClose(BuildContext context) {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: MSpacing.md),
          child: Center(
            child: Container(
              width: 48.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: MColors.gray800,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: context.leftPadding + MSpacing.md,
            right: context.rightPadding + MSpacing.md,
            top: MSpacing.md,
            bottom: MSpacing.md,
          ),
          child: Row(
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
        ),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}
