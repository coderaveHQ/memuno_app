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
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/notifications/application/mutations/mark_all_notifications_read_mutation.dart';
import 'package:memuno_app/src/features/notifications/application/mutations/mark_notification_read_mutation.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notification_target_route_mapper_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_list_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/resolve_notification_push_intent_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/application/services/notification_target_route_mapper.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_navigation_target.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/resolve_notification_push_intent_usecase.dart';
import 'package:memuno_app/src/features/notifications/presentation/widgets/notification_list_item.dart';

/// Notifications overview page with search, pagination, and read actions.
class NotificationsPage extends HookConsumerWidget {
  /// Creates the notifications page.
  const NotificationsPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _onMarkAllRead(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      markAllNotificationsReadMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref.read(notificationsListProvider.notifier).markAllAsRead();
    });
  }

  Future<void> _onOpenNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationListPageItemEntity notification,
  ) async {
    final Mutation<void> mutation = ref.read(
      markNotificationReadMutationProvider(notification.notificationId),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(notificationsListProvider.notifier)
          .markAsRead(notification);
    });

    if (!context.mounted) {
      return;
    }

    final ResolveNotificationPushIntentUsecase intentResolver = ref.read(
      resolveNotificationPushIntentUsecaseProvider,
    );
    final NotificationTargetRouteMapper routeMapper = ref.read(
      notificationTargetRouteMapperProvider,
    );
    final NotificationNavigationTarget target = intentResolver.fromNotification(
      notification,
    );

    await _pushWithFallback(context, routeMapper, target);
  }

  Future<void> _pushWithFallback(
    BuildContext context,
    NotificationTargetRouteMapper routeMapper,
    NotificationNavigationTarget target,
  ) async {
    final GoRouter router = GoRouter.of(context);
    try {
      await router.push(routeMapper.toLocation(target));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      await router.push(routeMapper.notificationsLocation());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController searchController = useTextEditingController();

    useEffect(() {
      final NotificationsList notifier = ref.read(
        notificationsListProvider.notifier,
      );

      unawaited(notifier.clearSearch());

      void listener() {
        notifier.applySearchDebounced(searchController.text);
      }

      searchController.addListener(listener);
      return () {
        notifier.cancelPendingSearch();
        searchController.removeListener(listener);
      };
    }, <Object?>[searchController]);

    final AsyncValue<
      PaginatedListState<
        NotificationListPageItemEntity,
        NotificationCursorEntity
      >
    >
    notificationsState = ref.watch(notificationsListProvider);

    final Mutation<void> markAllMutation = ref.watch(
      markAllNotificationsReadMutationProvider,
    );
    final MutationState<void> markAllState = ref.watch(markAllMutation);

    final bool hasUnread =
        notificationsState.asData?.value.items.any(
          (NotificationListPageItemEntity item) => !item.notificationIsRead,
        ) ??
        false;

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.notificationsTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
        trailing: <MAppBarButton>[
          MAppBarButton(
            isEnabled: hasUnread && !markAllState.isPending,
            onPressed: () => _onMarkAllRead(ref),
            icon: LucideIcons.check_check,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MSpacing.md,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
              bottom: MSpacing.md,
            ),
            child: MTextField(
              controller: searchController,
              icon: LucideIcons.search,
              label: l10n.notificationsSearchLabel,
              hint: l10n.notificationsSearchHint,
            ),
          ),
          Expanded(
            child:
                MAsyncList<
                  NotificationListPageItemEntity,
                  NotificationCursorEntity
                >(
                  provider: notificationsListProvider,
                  emptyText: l10n.notificationsListEmpty,
                  loadMoreExtent: 220.0,
                  itemBuilder:
                      (
                        BuildContext context,
                        NotificationListPageItemEntity notification,
                      ) {
                        return NotificationListItem(
                          notification: notification,
                          onPressed: (NotificationListPageItemEntity item) {
                            unawaited(_onOpenNotification(context, ref, item));
                          },
                        );
                      },
                ),
          ),
        ],
      ),
    );
  }
}
