import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/string_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/features/profile/application/providers/current_user_profile_provider.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';

/// Home page shown after successful authentication.
class HomePage extends ConsumerWidget {
  /// Creates the home page.
  const HomePage({super.key});

  Future<void> _onProfile(BuildContext context) async {
    await const ProfileRoute().push<void>(context);
  }

  Future<void> _onSettings(BuildContext context) async {
    await const SettingsRoute().push<void>(context);
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    final AsyncValue<UserProfileEntity> _ = ref.refresh(
      currentUserProfileProvider,
    );
  }

  @override
  /// Builds the page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<UserProfileEntity> profileState = ref.watch(
      currentUserProfileProvider,
    );

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(
          text: profileState.when<String>(
            data: (UserProfileEntity profile) {
              return l10n.homeGreetingWithName(profile.name.firstName);
            },
            error: (Object _, StackTrace _) {
              return l10n.homeGreetingGeneric;
            },
            loading: () {
              return l10n.homeGreetingWithName('Florian');
            },
          ),
          isLoading: profileState.isLoading,
        ),
        avatar: MAppBarAvatar(
          onPressed: () => _onProfile(context),
          name: profileState.value?.name,
          isLoading: profileState.isLoading,
        ),
        trailing: <MAppBarButton>[
          MAppBarButton(icon: LucideIcons.bell),
          MAppBarButton(
            onPressed: () => _onSettings(context),
            icon: LucideIcons.settings,
          ),
        ],
      ),
      body: MRefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: context.screenHeight * 0.55,
              child: Center(
                child: Text(
                  l10n.homePullToRefreshHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
