import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import 'package:memuno_app/src/app/widgets/app_text_field.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/auth/application/mutations/change_email_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/change_email_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/change_email_usecase.dart';

/// Page for requesting an email change.
class ChangeEmailPage extends HookConsumerWidget {
  /// Creates the change email page.
  const ChangeEmailPage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final Mutation<void> mutation = ref.watch(changeEmailMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState is MutationPending<void>;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthUserEntity? currentUser = ref.watch(currentUserProvider);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsChangeEmailTitle,
        subtitle: l10n.settingsChangeEmailSubtitle,
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
                      l10n.settingsChangeEmailCurrentEmail(
                        currentUser?.email ?? '-',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppGap.v(spacing.md),
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.email],
                      labelText: l10n.settingsChangeEmailNewEmailLabel,
                    ),
                    AppGap.v(spacing.lg),
                    AppButton.primary(
                      onPressed: isLoading
                          ? null
                          : () => _submit(ref, emailController.text),
                      isLoading: isLoading,
                      child: Text(l10n.settingsChangeEmailSubmitButton),
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

  /// Submits the current form values through the mutation pipeline.
  Future<void> _submit(WidgetRef ref, String email) async {
    final Mutation<void> mutation = ref.read(changeEmailMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final ChangeEmailUsecase usecase = tx.get(changeEmailUsecaseProvider);
      await usecase(
        email: email.trim(),
        redirectTo: AppEnv.authCallbackRedirect,
      );
    });
  }
}
