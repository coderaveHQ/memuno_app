import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_button_variant.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';

class MButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? background;
  final Color? foreground;
  final MButtonVariant variant;
  final String? title;

  const MButton({
    super.key,
    required this.variant,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.background,
    this.foreground,
    this.title,
  });

  const MButton.primary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.background,
    this.foreground,
    this.title,
  }) : variant = MButtonVariant.primary;

  const MButton.secondary({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.background,
    this.foreground,
    this.title,
  }) : variant = MButtonVariant.secondary;

  const MButton.destructive({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.background,
    this.foreground,
    this.title,
  }) : variant = MButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    return MTappable(
      onPressed: onPressed,
      isEnabled: isEnabled,
      child: Container(
        width: double.infinity,
        height: 48.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: variant.backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: isLoading
            ? MCircularProgressIndicator(
                color: foreground ?? variant.foregroundColor,
              )
            : MText.h5(
                text: title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                alignment: TextAlign.center,
                style: TextStyle(color: foreground ?? variant.foregroundColor),
              ),
      ),
    );
  }
}
