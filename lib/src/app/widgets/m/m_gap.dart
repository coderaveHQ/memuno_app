import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';

class MGap extends StatelessWidget {
  final double value;

  const MGap(this.value, {super.key});

  const MGap.xxs({super.key}) : value = MSpacing.xxs;

  const MGap.xs({super.key}) : value = MSpacing.xs;

  const MGap.sm({super.key}) : value = MSpacing.sm;

  const MGap.md({super.key}) : value = MSpacing.md;

  const MGap.lg({super.key}) : value = MSpacing.lg;

  const MGap.xl({super.key}) : value = MSpacing.xl;

  const MGap.xxl({super.key}) : value = MSpacing.xxl;

  @override
  Widget build(BuildContext context) {
    return Gap(value);
  }
}
