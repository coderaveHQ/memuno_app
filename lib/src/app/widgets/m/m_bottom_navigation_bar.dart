import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

class MBottomNavigationBar extends StatelessWidget {
  final List<MBottomNavigationBarItem> items;
  final MBottomNavigationBarAction? action;

  const MBottomNavigationBar({super.key, required this.items, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(
        bottom: context.bottomPadding + 2.0,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IntrinsicWidth(
            child: Container(
              height: kBottomNavigationBarHeight - 4.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  (kBottomNavigationBarHeight - 4.0) / 2.0,
                ),
                color: MColors.gray800,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: MSpacing.xs,
                children: List<Widget>.generate(items.length, (int index) {
                  final MBottomNavigationBarItem item = items[index];
                  return item;
                }),
              ),
            ),
          ),
          if (action != null)
            Padding(
              padding: EdgeInsetsGeometry.only(left: MSpacing.sm),
              child: action,
            ),
        ],
      ),
    );
  }
}

class MBottomNavigationBarItem extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final String? title;
  final bool isSelected;

  const MBottomNavigationBarItem({
    super.key,
    this.onPressed,
    this.icon,
    this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets itemPadding = const EdgeInsets.symmetric(
      vertical: MSpacing.sm,
      horizontal: MSpacing.md,
    );
    final Color unselectedColor = MColors.gray400;
    final Color selectedColor = MColors.yellow400;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isSelected ? 1.0 : 0.0),
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 500),
      builder: (BuildContext context, double t, Widget? _) {
        return Material(
          color: Color.lerp(
            selectedColor.withValues(alpha: 0.0),
            selectedColor.withValues(alpha: 0.1),
            t,
          ),
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            focusColor: selectedColor.withValues(alpha: 0.1),
            highlightColor: selectedColor.withValues(alpha: 0.1),
            splashColor: selectedColor.withValues(alpha: 0.1),
            hoverColor: selectedColor.withValues(alpha: 0.1),
            child: Padding(
              padding:
                  itemPadding - EdgeInsets.only(right: itemPadding.right * t),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: Color.lerp(unselectedColor, selectedColor, t),
                    size: 24.0,
                  ),
                  ClipRect(
                    clipBehavior: Clip.antiAlias,
                    child: Align(
                      alignment: Alignment(-0.2, 0.0),
                      widthFactor: t,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: itemPadding.left / 2,
                          right: itemPadding.right,
                        ),
                        child: MText.h5(
                          text: title,
                          style: TextStyle(
                            color: Color.lerp(
                              selectedColor.withValues(alpha: 0.0),
                              selectedColor,
                              t,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MBottomNavigationBarAction extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final bool isLoading;

  const MBottomNavigationBarAction({
    super.key,
    this.onPressed,
    this.icon,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MIconButton.primary(
      onPressed: onPressed,
      isEnabled: isEnabled,
      isLoading: isLoading,
      dimension: kBottomNavigationBarHeight - 4.0,
      foreground: MColors.gray100,
      background: MColors.gray800,
      icon: icon,
    );
  }
}
