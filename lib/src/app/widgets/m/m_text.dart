import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MText extends StatelessWidget {
  final String? text;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? alignment;
  final TextStyle? style;
  final bool isLoading;

  const MText({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    this.style,
    this.isLoading = false,
  });

  MText.h1({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h1.merge(style);

  MText.h2({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h2.merge(style);

  MText.h3({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h3.merge(style);

  MText.h4({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h4.merge(style);

  MText.h5({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h5.merge(style);

  MText.h6({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.h6.merge(style);

  MText.p({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.p.merge(style);

  MText.small({
    super.key,
    this.text,
    this.maxLines,
    this.overflow,
    this.alignment,
    TextStyle? style,
    this.isLoading = false,
  }) : style = MTypography.small.merge(style);

  @override
  Widget build(BuildContext context) {
    final Text child = Text(
      text ?? '',
      maxLines: maxLines,
      overflow: overflow,
      textAlign: alignment,
      style: style,
    );

    if (isLoading) {
      return Skeletonizer(enabled: true, child: child);
    }

    return child;
  }
}
