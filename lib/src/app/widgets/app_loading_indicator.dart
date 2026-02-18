import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';

/// Themed circular loading indicator used across the app.
class AppLoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator.
  const AppLoadingIndicator({super.key, this.size = 16.0, this.color});

  /// Indicator diameter in logical pixels.
  final double size;

  /// Optional indicator color override.
  final Color? color;

  @override
  /// Builds the loading indicator.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);
    final Color indicatorColor = color ?? colors.foreground;

    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      ),
    );
  }
}
