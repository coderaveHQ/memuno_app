import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';

/// Common text field widget aligned with the app theme.
class AppTextField extends StatelessWidget {
  /// Creates a themed text field.
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.suffixIcon,
    this.prefixIcon,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Label shown above the field.
  final String? labelText;

  /// Hint shown when empty.
  final String? hintText;

  /// Keyboard type override.
  final TextInputType? keyboardType;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Whether to obscure text input.
  final bool obscureText;

  /// Autofill hints for the platform.
  final Iterable<String>? autofillHints;

  /// Optional suffix icon widget.
  final Widget? suffixIcon;

  /// Optional prefix icon widget.
  final Widget? prefixIcon;

  /// Callback when submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the field is enabled.
  final bool enabled;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      enabled: enabled,
      cursorColor: colors.ring,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
