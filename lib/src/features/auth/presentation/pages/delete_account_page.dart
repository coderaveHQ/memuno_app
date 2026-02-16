import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/features/auth/application/mutations/delete_account_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/delete_account_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/delete_account_usecase.dart';

/// Page for deleting the currently signed-in account.
class DeleteAccountPage extends ConsumerWidget {
  /// Creates the delete account page.
  const DeleteAccountPage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> mutation = ref.watch(deleteAccountMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState is MutationPending<void>;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.settingsDeleteAccountSuccessMessage,
        );
      }
    });

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsDeleteAccountTitle,
        subtitle: l10n.settingsDeleteAccountSubtitle,
        onBack: () => context.pop(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppLayout.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      l10n.settingsDeleteAccountWarningBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppGap.v(spacing.lg),
                    AppButton.destructive(
                      onPressed: isLoading
                          ? null
                          : () => _confirmAndDelete(context, ref),
                      isLoading: isLoading,
                      child: Text(l10n.settingsDeleteAccountSubmitButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Confirms and executes account deletion.
  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteAccountConfirmTitle),
          content: Text(l10n.settingsDeleteAccountConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsDeleteAccountConfirmCancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settingsDeleteAccountConfirmDeleteButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final Mutation<void> mutation = ref.read(deleteAccountMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final DeleteAccountUsecase usecase = tx.get(deleteAccountUsecaseProvider);
      await usecase();
    });
  }
}
