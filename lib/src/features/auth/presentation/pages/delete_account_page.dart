import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/application/mutations/delete_account_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/delete_account_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:memuno_app/src/features/auth/presentation/widgets/delete_account_confirmation_dialog.dart';

/// Page for deleting the currently signed-in account.
class DeleteAccountPage extends ConsumerWidget {
  /// Creates the delete account page.
  const DeleteAccountPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Confirms and executes account deletion.
  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDeleteAccountConfirmationDialog(context);

    if (!(confirmed ?? false)) {
      return;
    }

    final Mutation<void> mutation = ref.read(deleteAccountMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final DeleteAccountUsecase usecase = tx.get(deleteAccountUsecaseProvider);
      await usecase();
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> mutation = ref.watch(deleteAccountMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState.isPending;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.deleteAccountSuccessMessage,
        );
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.deleteAccountTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            isEnabled: !isLoading,
            icon: LucideIcons.arrow_left,
          ),
        ],
      ),
      body: MCenter(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MSpacing.md,
            left: context.leftPadding + MSpacing.md,
            right: context.rightPadding + MSpacing.md,
            bottom: context.bottomPadding + MSpacing.md,
          ),
          child: Column(
            children: <Widget>[
              MText.p(
                text: l10n.deleteAccountWarningBody,
                alignment: TextAlign.center,
                style: TextStyle(color: MColors.gray100),
              ),
              const MGap.md(),
              MButton.primary(
                onPressed: () => _submit(context, ref),
                isLoading: isLoading,
                isEnabled: !isLoading,
                title: l10n.deleteAccountSubmitButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
