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
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/app/widgets/app_text_field.dart';
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

    final bool isOtpLoading = otpState is MutationPending<void>;
    final bool isPasswordLoading = passwordState is MutationPending<void>;
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

    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    return Scaffold(
      appBar: AppAppBar(title: l10n.signInTitle, subtitle: l10n.signInSubtitle),
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
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: l10n.signInEmailLabel,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                    ),
                    AppGap.v(spacing.md),
                    if (usePassword.value) ...<Widget>[
                      AppTextField(
                        controller: passwordController,
                        obscureText: !passwordVisible.value,
                        labelText: l10n.signInPasswordLabel,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
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
                        onPressed: isPasswordLoading
                            ? null
                            : () => _submitPassword(
                                ref,
                                emailController.text,
                                passwordController.text,
                              ),
                        isLoading: isPasswordLoading,
                        child: Text(l10n.signInSubmitWithPasswordButton),
                      ),
                      AppGap.v(spacing.sm),
                      AppButton.secondary(
                        onPressed: () {
                          usePassword.value = false;
                        },
                        child: Text(l10n.signInUseOtpButton),
                      ),
                    ] else ...<Widget>[
                      AppButton.primary(
                        onPressed: isOtpLoading
                            ? null
                            : () => _submitOtp(ref, emailController.text),
                        isLoading: isOtpLoading,
                        child: Text(l10n.signInSendOtpButton),
                      ),
                      AppGap.v(spacing.sm),
                      AppButton.secondary(
                        onPressed: () {
                          usePassword.value = true;
                        },
                        child: Text(l10n.signInSwitchToPasswordButton),
                      ),
                    ],
                    AppGap.v(spacing.md),
                    AppButton.ghost(
                      onPressed: () {
                        const SignUpRoute().push<void>(context);
                      },
                      child: Text(l10n.signInSignUpButton),
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
}
