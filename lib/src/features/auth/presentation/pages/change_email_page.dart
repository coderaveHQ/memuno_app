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
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
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

  void _onBack(BuildContext context) {
    context.pop();
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

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final Mutation<void> mutation = ref.watch(changeEmailMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState.isPending;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthUserEntity? currentUser = ref.watch(currentUserProvider);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        context.pop();
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.changeEmailTitle),
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
                text: l10n.changeEmailCurrentEmail(currentUser?.email ?? '-'),
              ),
              const MGap.md(),
              MTextField(
                icon: LucideIcons.mail,
                controller: emailController,
                inputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.email],
                label: l10n.changeEmailNewEmailLabel,
                isEnabled: !isLoading,
                autofocus: true,
              ),
              const MGap.md(),
              MButton.primary(
                onPressed: () => _submit(ref, emailController.text),
                isLoading: isLoading,
                isEnabled: !isLoading,
                title: l10n.changeEmailSubmitButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
