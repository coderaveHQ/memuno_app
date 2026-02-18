import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_button_variant.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';

class MCircularButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? background;
  final Color? foreground;
  final double dimension;
  final Widget? child;
  final MButtonVariant variant;

  const MCircularButton({
    super.key,
    required this.variant,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.child,
  });

  const MCircularButton.primary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.child,
  }) : variant = MButtonVariant.primary;

  const MCircularButton.secondary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.child,
  }) : variant = MButtonVariant.secondary;

  const MCircularButton.destructive({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.child,
  }) : variant = MButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    return MTappable(
      onPressed: onPressed,
      isEnabled: isEnabled,
      child: Container(
        width: dimension,
        height: dimension,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? variant.backgroundColor,
          borderRadius: BorderRadius.circular(dimension / 2.0),
        ),
        child: isLoading
            ? MCircularProgressIndicator(
                color: foreground ?? variant.foregroundColor,
              )
            : child,
      ),
    );
  }
}
