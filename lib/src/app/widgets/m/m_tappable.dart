import 'package:flutter/material.dart';

class MTappable extends StatelessWidget {
  final void Function()? onPressed;
  final bool isEnabled;
  final Widget? child;

  const MTappable({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: isEnabled ? onPressed : null, child: child);
  }
}
