import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_typography.dart';
import 'package:pinput/pinput.dart';

class MPinPut extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final void Function(String)? onCompleted;
  final bool autofocus;
  final bool isEnabled;

  const MPinPut({
    super.key,
    this.length = 6,
    this.controller,
    this.onCompleted,
    this.autofocus = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double dimension = 56.0;
    final PinTheme defaultPinTheme = PinTheme(
      width: dimension,
      height: dimension,
      textStyle: MTypography.baseTextStyle.copyWith(
        fontWeight: FontWeight.w400,
        color: MColors.gray100,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 1.5, color: MColors.gray800),
      ),
    );

    return Pinput(
      enabled: isEnabled,
      onCompleted: onCompleted,
      length: length,
      controller: controller,
      autofocus: autofocus,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration?.copyWith(
          border: Border.all(width: 1.5, color: MColors.gray100),
        ),
      ),
    );
  }
}
