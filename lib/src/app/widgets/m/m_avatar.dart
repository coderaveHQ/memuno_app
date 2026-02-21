import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/extensions/string_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_button_variant.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

class MAvatar extends StatelessWidget {
  final void Function()? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String? name;
  final double dimension;
  final Color? background;
  final Color? foreground;

  const MAvatar({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.name,
    this.dimension = 36.0,
    this.background,
    this.foreground,
  });

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    return MCircularButton(
      onPressed: onPressed,
      variant: MButtonVariant.secondary,
      isEnabled: isEnabled,
      isLoading: isLoading,
      dimension: dimension,
      background: background ?? MColors.gray200,
      foreground: foreground ?? MColors.gray900,
      child: MText.h4(
        text: name.initials,
        style: TextStyle(fontSize: dimension * 0.4),
      ),
    );
  }
}
