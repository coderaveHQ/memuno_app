import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  final MAppBarTitle? title;
  final MAppBarSubtitle? subtitle;
  final List<MAppBarButton> leading;
  final List<MAppBarButton> trailing;
  final MAppBarAvatar? avatar;
  final PreferredSizeWidget? bottom;

  const MAppBar({
    super.key,
    required this.context,
    this.title,
    this.subtitle,
    this.leading = const <MAppBarButton>[],
    this.trailing = const <MAppBarButton>[],
    this.avatar,
    this.bottom,
  });

  double get bottomHeight {
    if (bottom == null) return 0.0;
    return bottom!.preferredSize.height + 2 * (2.0 + MSpacing.md);
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(context.topPadding + kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonizerConfig(
      data: MTheme.sekeltonizerLightData,
      child: Container(
        width: preferredSize.width,
        height: preferredSize.height,
        decoration: BoxDecoration(
          color: MColors.gray100,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
        ),
        padding: EdgeInsets.only(
          top: context.topPadding,
          left: context.leftPadding + MSpacing.md,
          right: context.rightPadding + MSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: <Widget>[
                  ?avatar,
                  if (avatar != null && leading.isNotEmpty) const MGap.md(),
                  if (leading.isNotEmpty)
                    for (int i = 0; i < leading.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0.0 : MSpacing.md,
                        ),
                        child: leading[i],
                      ),
                  if ((avatar != null || leading.isNotEmpty) &&
                      (title != null || subtitle != null))
                    const MGap.md(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[?title, ?subtitle],
                    ),
                  ),
                  if (trailing.isNotEmpty &&
                      (avatar != null ||
                          leading.isNotEmpty ||
                          title != null ||
                          subtitle != null))
                    const MGap.md(),
                  for (int i = 0; i < trailing.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        right: i == trailing.length - 1 ? 0.0 : MSpacing.md,
                      ),
                      child: trailing[i],
                    ),
                ],
              ),
            ),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0 + MSpacing.md),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class MAppBarAvatar extends StatelessWidget {
  final void Function()? onPressed;
  final String? name;
  final bool isLoading;
  final bool isEnabled;

  const MAppBarAvatar({
    super.key,
    this.onPressed,
    this.name,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MAvatar(
      onPressed: onPressed,
      isEnabled: isEnabled,
      isLoading: isLoading,
      name: name,
      background: MColors.gray200,
      foreground: MColors.gray900,
      dimension: kToolbarHeight - 4.0,
    );
  }
}

class MAppBarTitle extends StatelessWidget {
  final String? text;
  final bool isLoading;

  const MAppBarTitle({super.key, this.text, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return MText.h4(
      text: text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      isLoading: isLoading,
    );
  }
}

class MAppBarSubtitle extends StatelessWidget {
  final String? text;
  final bool isLoading;

  const MAppBarSubtitle({super.key, this.text, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return MText.small(
      text: text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      isLoading: isLoading,
    );
  }
}

class MAppBarButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final bool isLoading;

  const MAppBarButton({
    super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MIconButton.secondary(
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      background: MColors.gray200,
      foreground: MColors.gray900,
      dimension: kToolbarHeight - 4.0,
    );
  }
}
