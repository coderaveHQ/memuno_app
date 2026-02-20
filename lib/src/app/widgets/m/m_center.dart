import 'package:flutter/material.dart';

class MCenter extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const MCenter({super.key, this.padding, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Center(child: child),
    );
  }
}
