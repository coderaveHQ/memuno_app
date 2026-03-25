import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/settings/application/mutations/unblock_blocked_user_mutation.dart';
import 'package:memuno_app/src/features/settings/application/providers/blocked_users_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_block_status_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// Settings page showing blocked users with unblock actions.
class BlockedUsersPage extends HookConsumerWidget {
  /// Creates the blocked-users settings page.
  const BlockedUsersPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController searchController = useTextEditingController();

    useEffect(() {
      final BlockedUsersList notifier = ref.read(
        blockedUsersListProvider.notifier,
      );
      unawaited(notifier.clearSearch());

      void onSearchChanged() {
        notifier.applySearchDebounced(searchController.text);
      }

      searchController.addListener(onSearchChanged);
      return () {
        notifier.cancelPendingSearch();
        searchController.removeListener(onSearchChanged);
      };
    }, <Object?>[searchController]);

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(text: l10n.settingsBlockedUsersTitle),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          icon: LucideIcons.arrow_left,
        ),
      ],
    );

    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.only(top: appBar.preferredSize.height - 20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 20.0 + MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
                bottom: MSpacing.md,
              ),
              child: MTextField(
                controller: searchController,
                icon: LucideIcons.search,
                label: l10n.settingsBlockedUsersSearchLabel,
                hint: l10n.settingsBlockedUsersSearchHint,
              ),
            ),
            Expanded(
              child: MAsyncList<UserItemEntity, ListCursorEntity>(
                provider: blockedUsersListProvider,
                emptyText: l10n.settingsBlockedUsersEmpty,
                loadMoreExtent: 220.0,
                listPadding: EdgeInsets.only(bottom: context.bottomPadding),
                childPadding: EdgeInsets.only(
                  top: MSpacing.md,
                  bottom: context.bottomPadding,
                  left: context.leftPadding + MSpacing.md,
                  right: context.rightPadding + MSpacing.md,
                ),
                itemBuilder: (BuildContext context, UserItemEntity user) {
                  return _BlockedUserListItem(user: user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedUserListItem extends ConsumerWidget {
  const _BlockedUserListItem({required this.user});

  final UserItemEntity user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    final Mutation<void> unblockMutation = ref.watch(
      unblockBlockedUserMutationProvider(user.id),
    );
    final MutationState<void> unblockState = ref.watch(unblockMutation);
    final bool isUnblocking = unblockState is MutationPending<void>;

    ref.listen<MutationState<void>>(unblockMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.moderationUnblockSuccessMessage,
        );
      }
    });

    return MListTile(
      onPressed: isUnblocking
          ? null
          : () {
              UserDetailsRoute(userId: user.id).push<void>(context);
            },
      isEnabled: !isUnblocking,
      leading: MAvatar(name: user.name, dimension: 48.0),
      title: user.name,
      description:
          '${l10n.userDetailsFriendshipCodeLabel} ${user.friendshipCode}',
      trailing: MIconButton.secondary(
        onPressed: isUnblocking
            ? null
            : () {
                unawaited(_onOpenActions(context, ref, l10n));
              },
        isLoading: isUnblocking,
        icon: LucideIcons.ellipsis_vertical,
        dimension: 42.0,
      ),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }

  Future<void> _onOpenActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final _BlockedUserAction? action = await _showActionsSheet(context, l10n);
    if (action == null) {
      return;
    }

    if (action == _BlockedUserAction.unblockUser) {
      await _unblockUser(ref);
    }
  }

  Future<void> _unblockUser(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      unblockBlockedUserMutationProvider(user.id),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref.read(blockedUsersListProvider.notifier).unblockUser(user);
      ref.invalidate(userBlockStatusProvider(user.id));
      ref.invalidate(userDetailsProvider(user.id));
      ref.invalidate(friendshipsListProvider);
      ref.invalidate(friendshipRequestsListProvider);
    });
  }

  Future<_BlockedUserAction?> _showActionsSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showModalSheet<_BlockedUserAction>(
      context: context,
      useRootNavigator: true,
      swipeDismissible: true,
      builder: (BuildContext context) {
        return Sheet(
          initialOffset: const SheetOffset(1),
          snapGrid: const SheetSnapGrid.single(snap: SheetOffset(1)),
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            color: MColors.gray900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            clipBehavior: Clip.antiAlias,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: context.bottomPadding + MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MText.h4(
                    text: l10n.settingsBlockedUsersActionsTitle,
                    style: const TextStyle(color: MColors.gray100),
                  ),
                  const MGap.md(),
                  MButton.secondary(
                    onPressed: () {
                      Navigator.of(context).pop(_BlockedUserAction.unblockUser);
                    },
                    title: l10n.moderationActionUnblockUser,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _BlockedUserAction { unblockUser }
