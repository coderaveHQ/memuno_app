import 'package:flutter/material.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_out_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_out_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_out_usecase.dart';

/// Button that signs the current user out.
class SignOutButton extends ConsumerWidget {
  /// Creates the sign-out button.
  const SignOutButton({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> mutation = ref.watch(signOutMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState is MutationPending<void>;

    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return AppButton.ghost(
      onPressed: isLoading ? null : () => _submit(ref),
      isLoading: isLoading,
      child: Text(l10n.signOutButton),
    );
  }

  /// Submits the current form values through the mutation pipeline.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(signOutMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SignOutUsecase usecase = tx.get(signOutUsecaseProvider);
      await usecase();
    });
  }
}
