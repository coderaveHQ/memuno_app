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
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/app/widgets/app_text_field.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_up_with_email_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_up_with_email_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

/// Sign-up page for creating a new account.
class SignUpPage extends HookConsumerWidget {
  /// Creates the sign-up page.
  const SignUpPage({super.key});

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

    final bool isLoading = signUpState is MutationPending<void>;
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

    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.signUpTitle,
        subtitle: l10n.signUpSubtitle,
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
                    AppTextField(
                      controller: nameController,
                      labelText: l10n.signUpNameLabel,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.name],
                    ),
                    AppGap.v(spacing.md),
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: l10n.signUpEmailLabel,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                    ),
                    AppGap.v(spacing.md),
                    AppTextField(
                      controller: passwordController,
                      obscureText: !passwordVisible.value,
                      labelText: l10n.signUpPasswordLabel,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible.value
                              ? LucideIcons.eye_off
                              : LucideIcons.eye,
                        ),
                        onPressed: () {
                          passwordVisible.value = !passwordVisible.value;
                        },
                      ),
                    ),
                    AppGap.v(spacing.lg),
                    AppButton.primary(
                      onPressed: isLoading
                          ? null
                          : () => _submitSignUp(
                              ref,
                              nameController.text,
                              emailController.text,
                              passwordController.text,
                            ),
                      isLoading: isLoading,
                      child: Text(l10n.signUpCreateAccountButton),
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

  /// Submits the sign-up payload through the mutation pipeline.
  Future<void> _submitSignUp(
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
}
