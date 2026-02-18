import 'package:flutter/material.dart';

class MTypography {
  static const String fontFamily = 'Switzer';

  static const TextStyle baseTextStyle = TextStyle(fontFamily: fontFamily);

  static TextStyle h1 = baseTextStyle.merge(
    const TextStyle(fontSize: 36.0, height: 1.2, fontWeight: FontWeight.w700),
  );

  static TextStyle h2 = baseTextStyle.merge(
    const TextStyle(fontSize: 32.0, height: 1.25, fontWeight: FontWeight.w700),
  );

  static TextStyle h3 = baseTextStyle.merge(
    const TextStyle(fontSize: 24.0, height: 1.3, fontWeight: FontWeight.w600),
  );

  static TextStyle h4 = baseTextStyle.merge(
    const TextStyle(fontSize: 20.0, height: 1.35, fontWeight: FontWeight.w600),
  );

  static TextStyle h5 = baseTextStyle.merge(
    const TextStyle(fontSize: 16.0, height: 1.4, fontWeight: FontWeight.w600),
  );

  static TextStyle h6 = baseTextStyle.merge(
    const TextStyle(fontSize: 14.0, height: 1.4, fontWeight: FontWeight.w600),
  );

  static TextStyle p = baseTextStyle.merge(
    const TextStyle(fontSize: 14.0, height: 1.3, fontWeight: FontWeight.w400),
  );

  static TextStyle small = baseTextStyle.merge(
    const TextStyle(fontSize: 12.0, height: 1.2, fontWeight: FontWeight.w400),
  );
}
