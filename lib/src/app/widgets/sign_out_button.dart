import 'package:flutter/material.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/application/providers/sign_out_with_push_cleanup_usecase_provider.dart';
import 'package:memuno_app/src/app/application/usecases/sign_out_with_push_cleanup_usecase.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_out_mutation.dart';

/// Button that signs the current user out.
class SignOutButton extends ConsumerWidget {
  /// Creates the sign-out button.
  const SignOutButton({super.key});

  /// Submits the current form values through the mutation pipeline.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(signOutMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SignOutWithPushCleanupUsecase usecase = tx.get(
        signOutWithPushCleanupUsecaseProvider,
      );
      await usecase();
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> mutation = ref.watch(signOutMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState.isPending;

    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MButton.secondary(
      onPressed: () => _submit(ref),
      isLoading: isLoading,
      isEnabled: !isLoading,
      title: l10n.signOutButton,
    );
  }
}
