import 'dart:async';

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
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_update_name_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/update_group_name_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/update_group_name_usecase.dart';

/// Opens a dialog that updates one group's display name.
Future<bool> showUpdateGroupDetailsNameDialog(
  BuildContext context, {
  required String groupId,
  required String initialName,
}) async {
  final bool? didUpdate = await showMDialog<bool>(
    context,
    builder: (BuildContext _) {
      return UpdateGroupDetailsNameDialog(
        groupId: groupId,
        initialName: initialName,
      );
    },
  );

  return didUpdate ?? false;
}

/// Dialog widget that submits a group-name update mutation.
class UpdateGroupDetailsNameDialog extends HookConsumerWidget {
  const UpdateGroupDetailsNameDialog({
    super.key,
    required this.groupId,
    required this.initialName,
  });

  final String groupId;
  final String initialName;

  Future<void> _submit(WidgetRef ref, String name) async {
    final Mutation<void> mutation = ref.read(
      groupDetailsUpdateNameMutationProvider(groupId),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final UpdateGroupNameUsecase usecase = tx.get(
        updateGroupNameUsecaseProvider,
      );
      await usecase(groupId: groupId, name: name);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController controller = useTextEditingController(
      text: initialName,
    );

    final Mutation<void> mutation = ref.watch(
      groupDetailsUpdateNameMutationProvider(groupId),
    );
    final MutationState<void> mutationState = ref.watch(mutation);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsUpdateNameSuccessMessage,
        );
        context.pop(true);
      }
    });

    return MDialog(
      title: l10n.groupDetailsUpdateNameDialogTitle,
      child: Column(
        children: <Widget>[
          MTextField(
            controller: controller,
            isEnabled: !mutationState.isPending,
            icon: LucideIcons.tag,
            label: l10n.groupsCreateNameFieldLabel,
            inputType: TextInputType.name,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.name],
            maxLength: 64,
            autofocus: true,
          ),
          const MGap.md(),
          MButton.primary(
            onPressed: mutationState.isPending
                ? null
                : () {
                    unawaited(_submit(ref, controller.text));
                  },
            title: l10n.groupDetailsUpdateNameSubmitButton,
            isEnabled: !mutationState.isPending,
            isLoading: mutationState.isPending,
          ),
        ],
      ),
    );
  }
}
