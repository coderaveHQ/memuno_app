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
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/create_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/create_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

Future<void> showFriendshipRequestSheet(BuildContext context) async {
  await showModalSheet<void>(
    context: context,
    useRootNavigator: true,
    swipeDismissible: true,
    viewportPadding: EdgeInsets.only(
      top: MediaQuery.viewPaddingOf(context).top,
    ),
    builder: (BuildContext _) {
      return const FriendshipRequestSheet();
    },
  );
}

class FriendshipRequestSheet extends HookConsumerWidget {
  const FriendshipRequestSheet({super.key});

  /// Submits the friendship-request create operation.
  Future<void> _submit(WidgetRef ref, String friendshipCode) async {
    final Mutation<FriendshipRequestListPageItemEntity> mutation = ref.read(
      createFriendshipRequestMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final CreateFriendshipRequestUsecase usecase = tx.get(
        createFriendshipRequestUsecaseProvider,
      );
      final FriendshipRequestListPageItemEntity created = await usecase(
        addresseeFriendshipCode: friendshipCode,
      );
      ref.read(friendshipRequestsListProvider.notifier).prependRequest(created);
      return created;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    final TextEditingController controller = useTextEditingController();

    final Mutation<FriendshipRequestListPageItemEntity> mutation = ref.watch(
      createFriendshipRequestMutationProvider,
    );
    final MutationState<FriendshipRequestListPageItemEntity> mutationState = ref
        .watch(mutation);
    final bool isSubmitting = mutationState.isPending;
    final double keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen<MutationState<FriendshipRequestListPageItemEntity>>(mutation, (
      prev,
      next,
    ) {
      if (next is MutationError<FriendshipRequestListPageItemEntity>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<FriendshipRequestListPageItemEntity>) {
        feedback.showSuccess(
          context,
          message: l10n.friendshipsRequestCreateSuccessMessage,
        );
        context.pop();
      }
    });

    return SheetPopScope<void>(
      canPop: !isSubmitting,
      child: Sheet(
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
              bottom: context.bottomPadding + MSpacing.md + keyboardBottomInset,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: MText.h4(
                        text: l10n.friendshipsAddDialogTitle,
                        style: const TextStyle(color: MColors.gray100),
                      ),
                    ),
                    const MGap.md(),
                    MIconButton.secondary(
                      onPressed: () => context.pop(),
                      icon: LucideIcons.x,
                      dimension: kToolbarHeight - 4.0,
                      isEnabled: !isSubmitting,
                    ),
                  ],
                ),
                const MGap.md(),
                MTextField(
                  controller: controller,
                  isEnabled: !isSubmitting,
                  icon: LucideIcons.user_search,
                  hint: '00000000',
                  label: l10n.friendshipsAddDialogFieldLabel,
                  inputType: TextInputType.number,
                  autofocus: true,
                ),
                const MGap.md(),
                MButton.primary(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          _submit(ref, controller.text.trim());
                        },
                  title: l10n.friendshipsAddDialogSubmitButton,
                  isEnabled: !isSubmitting,
                  isLoading: isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
