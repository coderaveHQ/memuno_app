import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

class MListTile extends StatelessWidget {
  final void Function()? onPressed;
  final String? title;
  final String? description;
  final String? details;
  final bool isEnabled;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const MListTile({
    super.key,
    this.onPressed,
    this.title,
    this.description,
    this.details,
    this.isEnabled = true,
    this.trailing,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return MTappable(
      onPressed: onPressed,
      isEnabled: isEnabled,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            if (leading != null)
              Padding(
                padding: EdgeInsetsGeometry.only(right: MSpacing.md),
                child: leading,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (title != null)
                    MText.h4(
                      text: title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: MColors.gray100),
                    ),
                  if (title != null && description != null) const MGap.xxs(),
                  if (description != null)
                    MText.small(
                      text: description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: MColors.gray400),
                    ),
                  if (description != null && details != null) const MGap.xxs(),
                  if (details != null)
                    MText.small(
                      text: details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: MColors.gray400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.only(left: MSpacing.md),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
