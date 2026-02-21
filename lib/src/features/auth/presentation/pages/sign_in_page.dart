import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/supabase_failure.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_in_with_otp_mutation.dart';
import 'package:memuno_app/src/features/auth/application/mutations/sign_in_with_password_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_in_with_otp_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/sign_in_with_password_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_in_with_otp_usecase.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_in_with_password_usecase.dart';

/// Sign-in page for authentication.
class SignInPage extends HookConsumerWidget {
  /// Creates the sign-in page.
  const SignInPage({super.key});

  /// Executes OTP sign-in via the mutation/usecase stack.
  Future<void> _submitOtp(WidgetRef ref, String email) async {
    final Mutation<void> mutation = ref.read(signInWithOtpMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SignInWithOtpUsecase usecase = tx.get(signInWithOtpUsecaseProvider);
      await usecase(
        email: email.trim(),
        redirectTo: AppEnv.authCallbackRedirect,
      );
    });
  }

  /// Executes password sign-in via the mutation/usecase stack.
  Future<void> _submitPassword(
    WidgetRef ref,
    String email,
    String password,
  ) async {
    final Mutation<void> mutation = ref.read(
      signInWithPasswordMutationProvider,
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SignInWithPasswordUsecase usecase = tx.get(
        signInWithPasswordUsecaseProvider,
      );
      await usecase(email: email.trim(), password: password);
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final ValueNotifier<bool> usePassword = useState<bool>(false);
    final ValueNotifier<bool> passwordVisible = useState<bool>(false);

    final Mutation<void> otpMutation = ref.watch(signInWithOtpMutationProvider);
    final Mutation<void> passwordMutation = ref.watch(
      signInWithPasswordMutationProvider,
    );

    final MutationState<void> otpState = ref.watch(otpMutation);
    final MutationState<void> passwordState = ref.watch(passwordMutation);

    final bool isOtpLoading = otpState.isPending;
    final bool isPasswordLoading = passwordState.isPending;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(otpMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(context, message: l10n.signInOtpSentMessage);
        VerifySignInRoute(emailController.text.trim()).push<void>(context);
      }
    });

    ref.listen<MutationState<void>>(passwordMutation, (previous, next) {
      if (next is MutationError<void>) {
        if (next.error is SupabaseFailureWrapper &&
            (next.error as SupabaseFailureWrapper).failure
                is SupabaseAuthFailure &&
            ((next.error as SupabaseFailureWrapper).failure
                        as SupabaseAuthFailure)
                    .code ==
                'email_not_confirmed') {
          feedback.showInfo(
            context,
            message: l10n.signInConfirmRegistrationMessage,
          );
          VerifySignUpRoute(emailController.text.trim()).push<void>(context);
          return;
        }
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.signInTitle),
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
                icon: LucideIcons.mail,
                controller: emailController,
                inputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.email],
                label: l10n.signInEmailLabel,
                isEnabled: !isOtpLoading && !isPasswordLoading,
              ),
              const MGap.md(),
              if (usePassword.value) ...<Widget>[
                MTextField(
                  icon: LucideIcons.lock,
                  isEnabled: !isOtpLoading && !isPasswordLoading,
                  controller: passwordController,
                  obscure: !passwordVisible.value,
                  label: l10n.signInPasswordLabel,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  action: MTextFieldAction(
                    onPressed: () {
                      passwordVisible.value = !passwordVisible.value;
                    },
                    isEnabled: !isOtpLoading && !isPasswordLoading,
                    icon: passwordVisible.value
                        ? LucideIcons.eye_off
                        : LucideIcons.eye,
                  ),
                ),
                const MGap.md(),
                MButton.primary(
                  onPressed: () => _submitPassword(
                    ref,
                    emailController.text,
                    passwordController.text,
                  ),
                  title: l10n.signInSubmitWithPasswordButton,
                  isLoading: isPasswordLoading,
                  isEnabled: !isOtpLoading && !isPasswordLoading,
                ),
                const MGap.md(),
                MButton.secondary(
                  onPressed: () {
                    usePassword.value = false;
                  },
                  title: l10n.signInUseOtpButton,
                  isEnabled: !isOtpLoading && !isPasswordLoading,
                ),
              ] else ...<Widget>[
                MButton.primary(
                  onPressed: () => _submitOtp(ref, emailController.text),
                  title: l10n.signInSendOtpButton,
                  isLoading: isOtpLoading,
                  isEnabled: !isOtpLoading && !isPasswordLoading,
                ),
                const MGap.md(),
                MButton.secondary(
                  onPressed: () {
                    usePassword.value = true;
                  },
                  title: l10n.signInSwitchToPasswordButton,
                  isEnabled: !isOtpLoading && !isPasswordLoading,
                ),
              ],
              const MGap.md(),
              MButton.secondary(
                onPressed: () {
                  const SignUpRoute().push<void>(context);
                },
                isEnabled: !isOtpLoading && !isPasswordLoading,
                title: l10n.signInSignUpButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
