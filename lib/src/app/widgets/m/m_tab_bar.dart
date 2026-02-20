import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_typography.dart';

class MTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<String>? titles;

  const MTabBar({super.key, this.controller, this.titles});

  @override
  Size get preferredSize => Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: preferredSize.width,
      height: preferredSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: MColors.gray200,
      ),
      child: TabBar(
        controller: controller,
        labelColor: MColors.gray900,
        unselectedLabelColor: MColors.gray500,
        labelStyle: MTypography.h6.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: MTypography.h6.copyWith(
          fontWeight: FontWeight.w400,
        ),
        indicator: BoxDecoration(
          color: MColors.gray100,
          borderRadius: BorderRadius.circular(20.0 - MSpacing.xxs),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.all(MSpacing.xxs),
        labelPadding: const EdgeInsets.symmetric(horizontal: MSpacing.lg),
        tabAlignment: TabAlignment.fill,
        dividerHeight: 0.0,
        tabs: (titles ?? <String>[])
            .map((String title) => Tab(text: title))
            .toList(),
      ),
    );
  }
}
