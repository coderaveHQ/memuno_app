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
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/auth/application/mutations/change_password_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/change_password_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/change_password_usecase.dart';

/// Page for changing the current user's password.
class ChangePasswordPage extends HookConsumerWidget {
  /// Creates the change password page.
  const ChangePasswordPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Submits the current form values through the mutation pipeline.
  Future<void> _submit(WidgetRef ref, String password) async {
    final Mutation<void> mutation = ref.read(changePasswordMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final ChangePasswordUsecase usecase = tx.get(
        changePasswordUsecaseProvider,
      );
      await usecase(password: password);
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController passwordController = useTextEditingController();
    final ValueNotifier<bool> passwordVisible = useState<bool>(false);

    final Mutation<void> mutation = ref.watch(changePasswordMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState.isPending;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.changePasswordSuccessMessage,
        );
        context.pop();
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.changePasswordTitle),
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
                icon: LucideIcons.lock,
                controller: passwordController,
                obscure: !passwordVisible.value,
                label: l10n.changePasswordNewPasswordLabel,
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
                onPressed: () => _submit(ref, passwordController.text),
                isLoading: isLoading,
                isEnabled: !isLoading,
                title: l10n.changePasswordSubmitButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
