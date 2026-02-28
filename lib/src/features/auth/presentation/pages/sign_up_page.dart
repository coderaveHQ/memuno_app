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
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_up_with_email_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_up_with_email_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

/// Sign-up page for creating a new account.
class SignUpPage extends HookConsumerWidget {
  /// Creates the sign-up page.
  const SignUpPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Submits the sign-up payload through the mutation pipeline.
  Future<void> _submit(
    WidgetRef ref,
    String name,
    String email,
    String password,
  ) async {
    final Mutation<void> mutation = ref.read(signUpWithEmailMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SignUpWithEmailUsecase usecase = tx.get(
        signUpWithEmailUsecaseProvider,
      );
      await usecase(
        name: name.trim(),
        email: email.trim(),
        password: password,
        redirectTo: AppEnv.authCallbackRedirect,
      );
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = useTextEditingController();
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final ValueNotifier<bool> passwordVisible = useState<bool>(false);

    final Mutation<void> signUpMutation = ref.watch(
      signUpWithEmailMutationProvider,
    );
    final MutationState<void> signUpState = ref.watch(signUpMutation);

    final bool isLoading = signUpState.isPending;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(signUpMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showInfo(
          context,
          message: l10n.signUpConfirmRegistrationMessage,
        );
        VerifySignUpRoute(emailController.text.trim()).push<void>(context);
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.signUpTitle),
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
              MTextField(
                icon: LucideIcons.tag,
                controller: nameController,
                inputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                label: l10n.signUpNameLabel,
                isEnabled: !isLoading,
                autofocus: true,
              ),
              const MGap.md(),
              MTextField(
                icon: LucideIcons.mail,
                controller: emailController,
                inputType: TextInputType.emailAddress,
                label: l10n.signUpEmailLabel,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                isEnabled: !isLoading,
              ),
              const MGap.md(),
              MTextField(
                icon: LucideIcons.lock,
                controller: passwordController,
                obscure: !passwordVisible.value,
                label: l10n.signUpPasswordLabel,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
                action: MTextFieldAction(
                  onPressed: () {
                    passwordVisible.value = !passwordVisible.value;
                  },
                  isEnabled: !isLoading,
                  icon: passwordVisible.value
                      ? LucideIcons.eye_off
                      : LucideIcons.eye,
                ),
                isEnabled: !isLoading,
              ),
              const MGap.md(),
              MButton.primary(
                onPressed: () => _submit(
                  ref,
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                ),
                isLoading: isLoading,
                title: l10n.signUpCreateAccountButton,
                isEnabled: !isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
