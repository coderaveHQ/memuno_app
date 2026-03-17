import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/groups/application/providers/group_create_draft_controller_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_create_draft_state_entity.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/groups_page.dart';

/// Step 1 page for naming a new group in the sheet flow.
class GroupCreateNameSheetPage extends HookConsumerWidget {
  const GroupCreateNameSheetPage({super.key});

  void _onClose(BuildContext context) {
    GroupsRoute(tab: GroupsPageTab.groups.routeValue).go(context);
  }

  void _onContinue(BuildContext context) {
    const GroupCreateMembersSheetRoute().push<void>(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GroupCreateDraftStateEntity draft = ref.watch(
      groupCreateDraftControllerProvider,
    );
    final TextEditingController nameController = useTextEditingController(
      text: draft.name,
    );

    useEffect(() {
      void listener() {
        ref
            .read(groupCreateDraftControllerProvider.notifier)
            .setName(nameController.text);
      }

      nameController.addListener(listener);
      return () {
        nameController.removeListener(listener);
      };
    }, <Object?>[nameController]);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: MSpacing.md,
          bottom: context.bottomPadding + MSpacing.md,
          left: context.leftPadding + MSpacing.md,
          right: context.rightPadding + MSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: MIconButton.secondary(
                onPressed: () => _onClose(context),
                icon: LucideIcons.x,
                dimension: 42.0,
              ),
            ),
            const MGap.sm(),
            MText.h3(
              text: l10n.groupsCreateNameTitle,
              style: const TextStyle(color: MColors.gray100),
            ),
            const MGap.xs(),
            MText.small(
              text: l10n.groupsCreateNameSubtitle,
              style: const TextStyle(color: MColors.gray400),
            ),
            const MGap.lg(),
            MTextField(
              controller: nameController,
              label: l10n.groupsCreateNameFieldLabel,
              hint: l10n.groupsCreateNameFieldHint,
              maxLength: 64,
              autofocus: true,
            ),
            const Spacer(),
            MButton.primary(
              title: l10n.groupsCreateNameContinueButton,
              isEnabled: draft.canProceedFromNameStep,
              onPressed: draft.canProceedFromNameStep
                  ? () => _onContinue(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
