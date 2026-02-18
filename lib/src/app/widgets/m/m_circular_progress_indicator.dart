import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MCircularProgressIndicator extends StatelessWidget {
  final double dimension;
  final Color? color;
  const MCircularProgressIndicator({
    super.key,
    this.dimension = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? MColors.gray900),
      ),
    );
  }
}
