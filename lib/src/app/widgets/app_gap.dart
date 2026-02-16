import 'package:flutter/widgets.dart';

/// Spacing widget aligned with the app spacing scale.
class AppGap extends StatelessWidget {
  /// Creates a vertical gap.
  const AppGap.v(this.size, {super.key}) : axis = Axis.vertical;

  /// Creates a horizontal gap.
  const AppGap.h(this.size, {super.key}) : axis = Axis.horizontal;

  /// Gap size.
  final double size;

  /// Axis along which to apply spacing.
  final Axis axis;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    return SizedBox(
      width: axis == Axis.horizontal ? size : 0,
      height: axis == Axis.vertical ? size : 0,
    );
  }
}
