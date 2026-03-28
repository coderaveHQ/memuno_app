import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_bottom_navigation_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';

class MScaffold extends StatelessWidget {
  /// App bar rendered at the top of the scaffold.
  final MAppBar? appBar;

  /// Main content of the scaffold.
  final Widget? body;

  /// Optional bottom navigation bar.
  final MBottomNavigationBar? bottomNavigationBar;

  final bool? resizeToAvoidBottomInset;

  final bool extendBody;

  final bool extendBodyBehindAppBar;

  const MScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: MColors.gray900,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: MColors.gray900,
        statusBarColor: MColors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: MColors.gray900,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}
