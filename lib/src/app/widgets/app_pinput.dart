import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:pinput/pinput.dart';

/// Themed PIN input aligned with the app style.
class AppPinput extends StatelessWidget {
  /// Creates a themed PIN input.
  const AppPinput({
    super.key,
    this.length = 6,
    this.controller,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.labelText,
  });

  /// Number of digits.
  final int length;

  /// Controller for the input.
  final TextEditingController? controller;

  /// Callback when the input is complete.
  final ValueChanged<String>? onCompleted;

  /// Callback when the input changes.
  final ValueChanged<String>? onChanged;

  /// Whether the input is enabled.
  final bool enabled;

  /// Optional label shown above the input.
  final String? labelText;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    final PinTheme baseTheme = PinTheme(
      width: 44,
      height: 48,
      textStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.foreground,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.input),
      ),
    );

    final PinTheme focusedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.ring, width: 2),
      ),
    );

    final PinTheme submittedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
    );

    final PinTheme errorTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.destructive),
      ),
    );

    final Widget input = Pinput(
      length: length,
      controller: controller,
      enabled: enabled,
      autofocus: false,
      showCursor: true,
      keyboardType: TextInputType.number,
      defaultPinTheme: baseTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: submittedTheme,
      errorPinTheme: errorTheme,
      separatorBuilder: (index) => const SizedBox(width: 8),
      onCompleted: onCompleted,
      onChanged: onChanged,
    );

    if (labelText == null || labelText!.isEmpty) {
      return input;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText!,
          style: textTheme.bodyMedium?.copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: 8),
        input,
      ],
    );
  }
}
