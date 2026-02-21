import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

enum MButtonVariant {
  primary(backgroundColor: MColors.gray100, foregroundColor: MColors.gray900),
  secondary(backgroundColor: MColors.gray800, foregroundColor: MColors.gray100),
  destructive(backgroundColor: MColors.red400, foregroundColor: MColors.white);

  final Color backgroundColor;
  final Color foregroundColor;

  const MButtonVariant({
    required this.backgroundColor,
    required this.foregroundColor,
  });
}
