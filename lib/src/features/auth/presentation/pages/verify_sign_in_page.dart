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
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/app/widgets/app_pinput.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/auth/application/mutations/resend_sign_in_otp_mutation.dart';
import 'package:memuno_app/src/features/auth/application/mutations/verify_sign_in_otp_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/resend_sign_in_otp_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/verify_sign_in_otp_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/resend_sign_in_otp_usecase.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/verify_sign_in_otp_usecase.dart';

/// Verification page shown after sign in with OTP.
class VerifySignInPage extends HookConsumerWidget {
  /// Email address being verified.
  final String email;

  /// Creates the verification page.
  const VerifySignInPage({super.key, required this.email});

  static const int _otpLength = 6;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = useTextEditingController();
    final ValueNotifier<String> otp = useState('');

    final Mutation<void> verifyMutation = ref.watch(
      verifySignInOtpMutationProvider,
    );
    final MutationState<void> verifyState = ref.watch(verifyMutation);
    final Mutation<void> resendMutation = ref.watch(
      resendSignInOtpMutationProvider,
    );
    final MutationState<void> resendState = ref.watch(resendMutation);

    final bool isLoading = verifyState is MutationPending<void>;
    final bool isResending = resendState is MutationPending<void>;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(verifyMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    ref.listen<MutationState<void>>(resendMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.verifySignInResentCodeMessage,
        );
      }
    });

    final AppShadColors colors = AppShadColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    final bool canSubmit = otp.value.length == _otpLength && !isLoading;

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.verifySignInTitle,
        subtitle: l10n.verifySignInInstruction(email),
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
                    AppPinput(
                      controller: controller,
                      length: _otpLength,
                      labelText: l10n.verifySignInCodeLabel,
                      onChanged: (value) => otp.value = value,
                      onCompleted: (value) {
                        otp.value = value;
                        if (value.length == _otpLength && !isLoading) {
                          _submitVerification(ref, email, value);
                        }
                      },
                    ),
                    AppGap.v(spacing.lg),
                    AppButton.primary(
                      onPressed: canSubmit
                          ? () => _submitVerification(ref, email, otp.value)
                          : null,
                      isLoading: isLoading,
                      child: Text(l10n.verifySignInConfirmButton),
                    ),
                    AppGap.v(spacing.md),
                    Text(
                      l10n.verifySignInNoEmailText,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppGap.v(spacing.sm),
                    AppButton.ghost(
                      onPressed: isResending
                          ? null
                          : () => _resendOtp(ref, email),
                      isLoading: isResending,
                      child: Text(l10n.verifySignInResendCodeButton),
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

  /// Submits the verification code for validation.
  Future<void> _submitVerification(
    WidgetRef ref,
    String email,
    String token,
  ) async {
    final Mutation<void> mutation = ref.read(verifySignInOtpMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final VerifySignInOtpUsecase usecase = tx.get(
        verifySignInOtpUsecaseProvider,
      );
      await usecase(email: email.trim(), token: token.trim());
    });
  }

  /// Requests a new OTP code for the current email.
  Future<void> _resendOtp(WidgetRef ref, String email) async {
    final Mutation<void> mutation = ref.read(resendSignInOtpMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final ResendSignInOtpUsecase usecase = tx.get(
        resendSignInOtpUsecaseProvider,
      );
      await usecase(
        email: email.trim(),
        redirectTo: AppEnv.authCallbackRedirect,
      );
    });
  }
}
