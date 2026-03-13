import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: 'Community'),
        trailing: <MAppBarButton>[MAppBarButton(icon: LucideIcons.search)],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: context.topPadding + kToolbarHeight - 20.0,
        ),
        child: SizedBox.shrink(),
      ),
    );
  }
}
