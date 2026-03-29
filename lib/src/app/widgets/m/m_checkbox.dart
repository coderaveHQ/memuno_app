import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MCheckbox extends StatelessWidget {
  final bool isChecked;
  final bool isEnabled;
  final void Function(bool?)? onChanged;

  const MCheckbox({
    super.key,
    this.isChecked = false,
    this.isEnabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      onChanged: isEnabled ? onChanged : null,
      value: isChecked,
      fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return MColors.yellow500;
        }
        return MColors.transparent;
      }),
      checkColor: Colors.white,
    );
  }
}
