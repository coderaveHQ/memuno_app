import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/create_meme/application/mutations/send_meme_mutation.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_controller_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/send_meme_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/send_meme_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/services/meme_widget_sync_service_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/services/meme_widget_sync_service.dart';

/// Page for selecting friendship recipients for one finalized meme.
class SendMemePage extends HookConsumerWidget {
  /// Finalized meme bytes received from the editor route.
  final List<int> memeBytes;

  /// Creates the send-meme page.
  const SendMemePage({super.key, required this.memeBytes});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Toggles one recipient selection by friendship-user identifier.
  void _onToggleRecipient(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
    String userId,
  ) {
    try {
      ref
          .read(memeEditorControllerProvider.notifier)
          .toggleRecipientSelection(userId);
    } catch (error) {
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Sends the finalized meme through mutation/usecase stack.
  Future<void> _submitSend({
    required WidgetRef ref,
    required MemeEditorStateEntity editorState,
    required Uint8List finalizedMemeBytes,
  }) async {
    final Mutation<void> mutation = ref.read(sendMemeMutationProvider);

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SendMemeUsecase usecase = tx.get(sendMemeUsecaseProvider);
      await usecase(state: editorState, memeBytes: finalizedMemeBytes);
    });
  }

  @override
  /// Builds the send-meme selection UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final Mutation<void> sendMutation = ref.watch(sendMemeMutationProvider);
    final MutationState<void> sendState = ref.watch(sendMutation);
    final bool isSending = sendState is MutationPending<void>;

    final MemeEditorStateEntity editorState = ref.watch(
      memeEditorControllerProvider,
    );
    final Uint8List finalizedMemeBytes = useMemoized<Uint8List>(
      () => Uint8List.fromList(memeBytes),
      <Object?>[memeBytes],
    );

    ref.listen<MutationState<void>>(sendMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        final MemeWidgetSyncService memeWidgetSyncService = ref.read(
          memeWidgetSyncServiceProvider,
        );
        unawaited(
          memeWidgetSyncService.sync(locale: Localizations.localeOf(context)),
        );
        feedback.showSuccess(context, message: l10n.sendMemeSuccessMessage);
        if (!context.mounted) {
          return;
        }
        const FeedRoute().go(context);
      }
    });

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (!context.mounted) {
          return;
        }

        try {
          ref
              .read(memeEditorControllerProvider.notifier)
              .clearRecipientSelection();
        } catch (error) {
          if (!context.mounted) {
            return;
          }
          feedback.resolveAndShowError(context, error);
        }
      });
      return null;
    }, const <Object?>[]);

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.sendMemeTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MAsyncList<FriendshipListPageItemEntity, FriendshipCursorEntity>(
              provider: friendshipsListProvider,
              emptyText: l10n.friendshipsListEmpty,
              loadMoreExtent: 220.0,
              listPadding: EdgeInsets.zero,
              childPadding: EdgeInsets.only(
                top: MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
                bottom: MSpacing.md,
              ),
              listChildPadding: EdgeInsets.only(
                top: MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
                bottom: MSpacing.md,
              ),
              itemBuilder:
                  (
                    BuildContext context,
                    FriendshipListPageItemEntity friendship,
                  ) {
                    final bool isSelected = editorState.isRecipientSelected(
                      friendship.user.id,
                    );
                    return MListTile(
                      onPressed: () {
                        _onToggleRecipient(
                          ref,
                          context,
                          feedback,
                          friendship.user.id,
                        );
                      },
                      isEnabled: !isSending,
                      leading: MAvatar(
                        name: friendship.user.name,
                        dimension: 48.0,
                      ),
                      title: friendship.user.name,
                      description:
                          '${l10n.friendshipsFriendsSincePrefix}: ${friendship.createdAt.formatDateOnly(fullDate: true)}',
                      trailing: MRadioIndicator(isSelected: isSelected),
                      padding: EdgeInsets.only(
                        top: MSpacing.md,
                        left: context.leftPadding + MSpacing.md,
                        right: context.rightPadding + MSpacing.md,
                        bottom: MSpacing.md,
                      ),
                    );
                  },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MSpacing.md,
              bottom: context.bottomPadding + MSpacing.md,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
            ),
            child: MButton.primary(
              title: l10n.sendMemeSubmitButton,
              isLoading: isSending,
              isEnabled:
                  finalizedMemeBytes.isNotEmpty &&
                  editorState.hasSelectedRecipients &&
                  !isSending,
              onPressed: () {
                unawaited(
                  _submitSend(
                    ref: ref,
                    editorState: editorState,
                    finalizedMemeBytes: finalizedMemeBytes,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
