import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/extensions/string_x.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:memuno_app/src/app/widgets/app_loading_indicator.dart';

/// Circular avatar that renders initials derived from a full name.
class AppAvatar extends StatelessWidget {
  /// Creates a themed avatar widget.
  const AppAvatar({
    super.key,
    this.name,
    this.onPressed,
    this.size = 36,
    this.isLoading = false,
  });

  /// Full name used to derive initials.
  final String? name;

  /// Optional tap callback to make the avatar act like a button.
  final VoidCallback? onPressed;

  /// Diameter of the avatar in logical pixels.
  final double size;

  final bool isLoading;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);
    final String initials = name.initials;

    final Widget avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.secondary,
        border: Border.all(color: colors.border),
      ),
      child: isLoading
          ? const AppLoadingIndicator()
          : Text(
              initials,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.secondaryForeground,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
    );

    if (onPressed == null) {
      return avatar;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(2), child: avatar),
      ),
    );
  }
}
