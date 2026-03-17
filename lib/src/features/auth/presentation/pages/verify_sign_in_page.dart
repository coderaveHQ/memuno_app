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
import 'package:memuno_app/src/app/widgets/m/m_pin_put.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
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

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Submits the verification code for validation.
  Future<void> _submit(WidgetRef ref, String email, String token) async {
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

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController otpController = useTextEditingController();

    final Mutation<void> verifyMutation = ref.watch(
      verifySignInOtpMutationProvider,
    );
    final MutationState<void> verifyState = ref.watch(verifyMutation);
    final Mutation<void> resendMutation = ref.watch(
      resendSignInOtpMutationProvider,
    );
    final MutationState<void> resendState = ref.watch(resendMutation);

    final bool isLoading = verifyState.isPending;
    final bool isResending = resendState.isPending;
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

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(text: l10n.verifySignInTitle),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          isEnabled: !isLoading && !isResending,
          icon: LucideIcons.arrow_left,
        ),
      ],
    );

    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.only(top: appBar.preferredSize.height - 20.0),
        child: MCenter(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 20.0 + MSpacing.md,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
              bottom: context.bottomPadding + MSpacing.md,
            ),
            child: Column(
              children: <Widget>[
                MPinPut(
                  controller: otpController,
                  length: 6,
                  isEnabled: !isLoading && !isResending,
                  onCompleted: (String value) {
                    _submit(ref, email, value);
                  },
                  autofocus: true,
                ),
                const MGap.md(),
                MButton.primary(
                  onPressed: () => _submit(ref, email, otpController.text),
                  isLoading: isLoading,
                  title: l10n.verifySignInConfirmButton,
                  isEnabled: !isLoading && !isResending,
                ),
                const MGap.md(),
                MButton.secondary(
                  onPressed: () => _resendOtp(ref, email),
                  isLoading: isResending,
                  title: l10n.verifySignInResendCodeButton,
                  isEnabled: !isLoading && !isResending,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
