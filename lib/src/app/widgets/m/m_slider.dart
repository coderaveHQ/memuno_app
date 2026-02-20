import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MSlider extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double value;
  final void Function(double)? onChanged;

  const MSlider({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: minValue,
      max: maxValue,
      value: value,
      activeColor: MColors.gray100,
      inactiveColor: MColors.gray700,
      onChanged: onChanged,
    );
  }
}
