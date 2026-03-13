import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_dialog.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/user_details/application/mutations/update_current_user_details_name_mutation.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/update_current_user_details_name_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/update_current_user_details_name_usecase.dart';

/// Opens a dialog that updates the current authenticated user's display name.
Future<void> showUpdateCurrentUserDetailsNameDialog(
  BuildContext context, {
  required String userId,
  required String initialName,
}) async {
  await showMDialog<void>(
    context,
    builder: (BuildContext _) {
      return UpdateCurrentUserDetailsNameDialog(
        userId: userId,
        initialName: initialName,
      );
    },
  );
}

/// Dialog widget that submits a current-user name update mutation.
class UpdateCurrentUserDetailsNameDialog extends HookConsumerWidget {
  /// Creates the dialog.
  const UpdateCurrentUserDetailsNameDialog({
    super.key,
    required this.userId,
    required this.initialName,
  });

  /// Authenticated user id whose cached details state should be updated.
  final String userId;

  /// Initial input value shown in the text field.
  final String initialName;

  /// Submits the name update operation through the mutation pipeline.
  Future<void> _submit(WidgetRef ref, String name) async {
    final String trimmedName = name.trim();
    final Mutation<void> mutation = ref.read(
      updateCurrentUserDetailsNameMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final UpdateCurrentUserDetailsNameUsecase usecase = tx.get(
        updateCurrentUserDetailsNameUsecaseProvider,
      );

      await usecase(name: trimmedName);
      ref.read(userDetailsProvider(userId).notifier).setName(trimmedName);
    });
  }

  @override
  /// Builds the update-name dialog UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController controller = useTextEditingController(
      text: initialName,
    );

    final Mutation<void> mutation = ref.watch(
      updateCurrentUserDetailsNameMutationProvider,
    );
    final MutationState<void> mutationState = ref.watch(mutation);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.userDetailsUpdateNameSuccessMessage,
        );
        context.pop();
      }
    });

    return MDialog(
      title: l10n.userDetailsUpdateNameDialogTitle,
      child: Column(
        children: <Widget>[
          MTextField(
            controller: controller,
            isEnabled: !mutationState.isPending,
            icon: LucideIcons.tag,
            label: l10n.signUpNameLabel,
            inputType: TextInputType.name,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.name],
            autofocus: true,
          ),
          const MGap.md(),
          MButton.primary(
            onPressed: () => _submit(ref, controller.text),
            title: l10n.userDetailsUpdateNameSubmitButton,
            isEnabled: !mutationState.isPending,
            isLoading: mutationState.isPending,
          ),
        ],
      ),
    );
  }
}
