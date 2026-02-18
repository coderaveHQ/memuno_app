import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_button_variant.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_button.dart';

class MIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? background;
  final Color? foreground;
  final double dimension;
  final IconData? icon;
  final MButtonVariant variant;

  const MIconButton({
    super.key,
    required this.variant,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.icon,
  });

  const MIconButton.primary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.icon,
  }) : variant = MButtonVariant.primary;

  const MIconButton.secondary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.icon,
  }) : variant = MButtonVariant.secondary;

  const MIconButton.destructive({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.dimension = 48.0,
    this.background,
    this.foreground,
    this.icon,
  }) : variant = MButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    return MCircularButton(
      variant: variant,
      onPressed: onPressed,
      isEnabled: isEnabled,
      isLoading: isLoading,
      dimension: dimension,
      background: background,
      child: Icon(
        icon,
        size: dimension * 0.5,
        color: foreground ?? variant.foregroundColor,
      ),
    );
  }
}
