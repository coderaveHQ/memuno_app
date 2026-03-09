import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/string_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/providers/current_user_profile_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/feed/application/providers/feed_list_provider.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_entity.dart';
import 'package:memuno_app/src/features/feed/presentation/widgets/feed_list_item.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';

/// Feed page shown after successful authentication.
class FeedPage extends ConsumerWidget {
  /// Creates the feed page.
  const FeedPage({super.key});

  Future<void> _onProfile(BuildContext context) async {
    await const ProfileRoute().push<void>(context);
  }

  Future<void> _onNotifications(BuildContext context) async {
    await const NotificationsRoute().push<void>(context);
  }

  Future<void> _onSettings(BuildContext context) async {
    await const SettingsRoute().push<void>(context);
  }

  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      final AsyncValue<UserProfileEntity> _ = ref.refresh(
        currentUserProfileProvider,
      );
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }

    try {
      await ref.read(feedListProvider.notifier).refresh();
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
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
          MAppBarButton(
            onPressed: () => _onNotifications(context),
            icon: LucideIcons.bell,
          ),
          MAppBarButton(
            onPressed: () => _onSettings(context),
            icon: LucideIcons.settings,
          ),
        ],
      ),
      body: MAsyncList<FeedListPageItemEntity, FeedCursorEntity>(
        provider: feedListProvider,
        emptyText: l10n.feedListEmpty,
        loadMoreExtent: 220.0,
        onRefresh: _onRefresh,
        listPadding: EdgeInsets.only(
          top: MSpacing.md,
          bottom:
              context.bottomPadding + kBottomNavigationBarHeight + MSpacing.md,
        ),
        separatorBuilder: (BuildContext _, int _) {
          return const MGap.sm();
        },
        itemBuilder: (BuildContext context, FeedListPageItemEntity feedItem) {
          return FeedListItem(feedItem: feedItem);
        },
      ),
    );
  }
}
