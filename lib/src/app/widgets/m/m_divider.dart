import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MDivider extends StatelessWidget {
  final Color? color;
  const MDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1.0, color: color ?? MColors.gray800);
  }
}
