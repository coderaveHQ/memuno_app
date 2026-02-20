import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MRadioIndicator extends StatelessWidget {
  final bool isSelected;
  const MRadioIndicator({super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: BoxBorder.all(
          width: 1.5,
          color: isSelected ? MColors.yellow400 : MColors.gray800,
        ),
      ),
      child: isSelected
          ? Container(
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MColors.yellow400,
              ),
            )
          : null,
    );
  }
}
