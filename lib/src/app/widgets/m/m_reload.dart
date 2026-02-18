import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

class MReload extends StatelessWidget {
  final EdgeInsets? padding;
  final String? text;
  final void Function()? onReload;
  const MReload({super.key, this.padding, this.text, this.onReload});

  @override
  Widget build(BuildContext context) {
    return MCenter(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (text != null)
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: MSpacing.md),
              child: MText.p(
                text: text,
                alignment: TextAlign.center,
                style: TextStyle(color: MColors.gray100),
              ),
            ),
          MTappable(
            onPressed: onReload,
            child: Icon(
              LucideIcons.rotate_ccw,
              color: MColors.gray100,
              size: 22.0,
            ),
          ),
        ],
      ),
    );
  }
}
