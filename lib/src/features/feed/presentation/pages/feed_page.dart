import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/string_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/feed/application/providers/feed_list_provider.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_entity.dart';
import 'package:memuno_app/src/features/feed/presentation/widgets/feed_list_item.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_unread_count_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';

/// Feed page shown after successful authentication.
class FeedPage extends ConsumerWidget {
  /// Creates the feed page.
  const FeedPage({super.key});

  Future<void> _onUserDetails(BuildContext context) async {
    await const CurrentUserDetailsRoute().push<void>(context);
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
    final String? currentUserId = ref.read(currentUserProvider)?.id;
    try {
      if (currentUserId != null) {
        final AsyncValue<UserDetailsEntity> _ = ref.refresh(
          userDetailsProvider(currentUserId),
        );
      }
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
    final String? currentUserId = ref.watch(currentUserProvider)?.id;
    final AsyncValue<UserDetailsEntity> userDetailsState = currentUserId == null
        ? const AsyncValue<UserDetailsEntity>.loading()
        : ref.watch(userDetailsProvider(currentUserId));
    final int unreadNotificationsCount =
        ref.watch(notificationsUnreadCountProvider).asData?.value ?? 0;

    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(
          text: userDetailsState.when<String>(
            data: (UserDetailsEntity userDetails) {
              return l10n.homeGreetingWithName(userDetails.name.firstName);
            },
            error: (Object _, StackTrace _) {
              return l10n.homeGreetingGeneric;
            },
            loading: () {
              return l10n.homeGreetingWithName('Florian');
            },
          ),
          isLoading: userDetailsState.isLoading,
        ),
        avatar: MAppBarAvatar(
          onPressed: () => _onUserDetails(context),
          name: userDetailsState.value?.name,
          isLoading: userDetailsState.isLoading,
        ),
        trailing: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onNotifications(context),
            icon: LucideIcons.bell,
            badgeCount: unreadNotificationsCount,
          ),
          MAppBarButton(
            onPressed: () => _onSettings(context),
            icon: LucideIcons.settings,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: context.topPadding + kToolbarHeight - 20.0,
        ),
        child: MAsyncList<FeedListPageItemEntity, FeedCursorEntity>(
          provider: feedListProvider,
          emptyText: l10n.feedListEmpty,
          loadMoreExtent: 220.0,
          onRefresh: _onRefresh,
          listPadding: EdgeInsets.only(
            top: 20.0 + MSpacing.md,
            bottom: context.bottomPadding + MSpacing.md,
          ),
          childPadding: EdgeInsets.only(
            top: 20.0 + MSpacing.md,
            bottom: context.bottomPadding + MSpacing.md,
            left: context.leftPadding + MSpacing.md,
            right: context.rightPadding + MSpacing.md,
          ),
          separatorBuilder: (BuildContext _, int _) {
            return const MGap.sm();
          },
          itemBuilder: (BuildContext context, FeedListPageItemEntity feedItem) {
            return FeedListItem(feedItem: feedItem);
          },
        ),
      ),
    );
  }
}
