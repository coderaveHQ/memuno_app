import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/profile/application/providers/current_user_profile_provider.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';
import 'package:memuno_app/src/infrastructure/share_plus/share_plus_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Profile page for viewing and updating account-level name data.
class ProfilePage extends HookConsumerWidget {
  /// Creates the profile page.
  const ProfilePage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _onFriendships(BuildContext context) async {
    await const FriendshipsRoute().push<void>(context);
  }

  Future<void> _onShareFriendshipCode(
    BuildContext context,
    WidgetRef ref,
    String friendshipCode,
  ) async {
    final SharePlus sharePlus = ref.read(sharePlusProvider);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    try {
      final ShareResult _ = await sharePlus.share(
        ShareParams(text: l10n.profileFriendshipCodeShareText(friendshipCode)),
      );
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
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
        title: MAppBarTitle(text: l10n.profileTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
        trailing: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onFriendships(context),
            icon: LucideIcons.users,
          ),
          MAppBarButton(
            onPressed: () => _onShareFriendshipCode(
              context,
              ref,
              profileState.value!.friendshipCode,
            ),
            icon: LucideIcons.share,
          ),
        ],
      ),
      body: MRefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MSpacing.xs,
            bottom: context.bottomPadding + MSpacing.md,
          ),
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MColors.gray100,
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MAvatar(
                        dimension: 56.0,
                        background: MColors.gray200,
                        foreground: MColors.gray900,
                        isLoading: profileState.isLoading,
                        name: profileState.value?.name,
                      ),
                      const MGap.lg(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MText.h3(
                              text: profileState.when<String>(
                                data: (UserProfileEntity profile) {
                                  return profile.name;
                                },
                                error: (Object _, StackTrace _) {
                                  return '???';
                                },
                                loading: () {
                                  return 'Florian Leeser';
                                },
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: profileState.isLoading,
                            ),
                            const MGap.xxs(),
                            MText.small(
                              text: profileState.when<String>(
                                data: (UserProfileEntity profile) {
                                  return '${l10n.profileJoinedAtLabel} ${profile.createdAt.formatDateOnly(fullDate: true)}';
                                },
                                error: (Object _, StackTrace _) {
                                  return '${l10n.profileJoinedAtLabel} ???';
                                },
                                loading: () {
                                  return '${l10n.profileJoinedAtLabel} ${DateTime.now().formatDateOnly(fullDate: true)}';
                                },
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: profileState.isLoading,
                            ),
                            const MGap.xxs(),
                            MText.small(
                              text: profileState.when<String>(
                                data: (UserProfileEntity profile) {
                                  return '${l10n.profileFriendshipCodeLabel} ${profile.friendshipCode}';
                                },
                                error: (Object _, StackTrace _) {
                                  return '${l10n.profileFriendshipCodeLabel} ???';
                                },
                                loading: () {
                                  return '${l10n.profileFriendshipCodeLabel} 00000000';
                                },
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: profileState.isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
