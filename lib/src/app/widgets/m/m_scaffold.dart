import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_bottom_navigation_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MScaffold extends StatelessWidget {
  final MAppBar? appBar;
  final Widget? body;
  final MBottomNavigationBar? bottomNavigationBar;

  const MScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: MColors.gray900,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: MColors.gray900,
        statusBarColor: MColors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: MColors.gray900,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
