import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_dialog.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/create_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/create_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';

Future<void> showFriendshipRequestDialog(BuildContext context) async {
  return await showMDialog<void>(
    context,
    builder: (BuildContext _) {
      return const FriendshipRequestDialog();
    },
  );
}

class FriendshipRequestDialog extends HookConsumerWidget {
  const FriendshipRequestDialog({super.key});

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

    return MDialog(
      title: l10n.friendshipsAddDialogTitle,
      child: Column(
        children: <Widget>[
          MTextField(
            controller: controller,
            isEnabled: !mutationState.isPending,
            icon: LucideIcons.user_search,
            hint: '00000000',
            label: l10n.friendshipsAddDialogFieldLabel,
            inputType: TextInputType.number,
          ),
          const MGap.md(),
          MButton.primary(
            onPressed: () => _submit(ref, controller.text.trim()),
            title: l10n.friendshipsAddDialogSubmitButton,
            isEnabled: !mutationState.isPending,
            isLoading: mutationState.isPending,
          ),
        ],
      ),
    );
  }
}
