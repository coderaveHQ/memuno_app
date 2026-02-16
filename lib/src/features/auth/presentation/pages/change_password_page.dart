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
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_button.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/app/widgets/app_text_field.dart';
import 'package:memuno_app/src/features/auth/application/mutations/change_password_mutation.dart';
import 'package:memuno_app/src/features/auth/application/providers/usecases/change_password_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/change_password_usecase.dart';

/// Page for changing the current user's password.
class ChangePasswordPage extends HookConsumerWidget {
  /// Creates the change password page.
  const ChangePasswordPage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController passwordController = useTextEditingController();
    final ValueNotifier<bool> passwordVisible = useState<bool>(false);

    final Mutation<void> mutation = ref.watch(changePasswordMutationProvider);
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isLoading = mutationState is MutationPending<void>;
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.settingsChangePasswordSuccessMessage,
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsChangePasswordTitle,
        subtitle: l10n.settingsChangePasswordSubtitle,
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
                      controller: passwordController,
                      obscureText: !passwordVisible.value,
                      labelText: l10n.settingsChangePasswordNewPasswordLabel,
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
                          : () => _submit(ref, passwordController.text),
                      isLoading: isLoading,
                      child: Text(l10n.settingsChangePasswordSubmitButton),
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
  Future<void> _submit(WidgetRef ref, String password) async {
    final Mutation<void> mutation = ref.read(changePasswordMutationProvider);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final ChangePasswordUsecase usecase = tx.get(
        changePasswordUsecaseProvider,
      );
      await usecase(password: password);
    });
  }
}
