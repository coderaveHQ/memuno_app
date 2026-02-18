import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const MRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: MColors.white,
      color: MColors.gray900,
      strokeWidth: 2.0,
      child: child,
    );
  }
}
