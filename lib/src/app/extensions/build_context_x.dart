import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenHeight => screenSize.height;
  double get screenWidth => screenSize.width;

  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get topPadding => padding.top;
  double get leftPadding => padding.left;
  double get rightPadding => padding.right;
  double get bottomPadding => padding.bottom;

  /// Current orientation.
  Orientation get orientation => MediaQuery.orientationOf(this);
}
