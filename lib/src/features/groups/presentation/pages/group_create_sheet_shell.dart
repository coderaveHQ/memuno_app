import 'package:flutter/material.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/features/groups/application/mutations/group_create_mutation.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// Root sheet container for the 2-step group-create flow.
class GroupCreateSheetShell extends ConsumerWidget {
  const GroupCreateSheetShell({super.key, required this.navigator});

  final Widget navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<GroupItemEntity> mutation = ref.watch(
      groupCreateMutationProvider,
    );
    final MutationState<GroupItemEntity> mutationState = ref.watch(mutation);
    final bool isSubmitting = mutationState is MutationPending<GroupItemEntity>;

    return SheetPopScope<void>(
      canPop: !isSubmitting,
      child: SheetKeyboardDismissible(
        dismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
          isContentScrollAware: true,
        ),
        child: PagedSheet(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            color: MColors.gray900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            clipBehavior: Clip.antiAlias,
          ),
          navigator: navigator,
        ),
      ),
    );
  }
}
