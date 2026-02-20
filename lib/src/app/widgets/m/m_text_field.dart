import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_typography.dart';

class MTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? inputType;
  final TextInputAction? textInputAction;
  final IconData? icon;
  final String? hint;
  final String? label;
  final bool obscure;
  final bool isEnabled;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;

  const MTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.inputType = TextInputType.text,
    this.textInputAction,
    this.icon,
    this.hint,
    this.label,
    this.obscure = false,
    this.isEnabled = true,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final InputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(width: 1.5, color: MColors.gray800),
    );

    final TextStyle defaultTextStyle = MTypography.baseTextStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: MColors.gray100,
    );

    return TextField(
      maxLength: maxLength,
      keyboardAppearance: Brightness.dark,
      controller: controller,
      focusNode: focusNode,
      autocorrect: false,
      enabled: isEnabled,
      readOnly: !isEnabled,
      keyboardType: inputType,
      textInputAction: textInputAction,
      canRequestFocus: isEnabled,
      obscureText: obscure,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: MColors.gray400,
      style: defaultTextStyle,
      decoration: InputDecoration(
        fillColor: MColors.gray800,
        contentPadding: const EdgeInsets.symmetric(horizontal: MSpacing.md),
        border: defaultBorder,
        errorBorder: defaultBorder,
        enabledBorder: defaultBorder,
        disabledBorder: defaultBorder,
        focusedErrorBorder: defaultBorder,
        focusedBorder: defaultBorder.copyWith(
          borderSide: defaultBorder.borderSide.copyWith(color: MColors.gray100),
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
        prefixIconColor: MColors.gray400,
        hintText: hint,
        hintStyle: defaultTextStyle.copyWith(color: MColors.gray400),
        floatingLabelStyle: defaultTextStyle,
        counterStyle: defaultTextStyle,
        labelText: label,
      ),
    );
  }
}
