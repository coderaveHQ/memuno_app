import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/delete_friendship_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';

class DeleteFriendshipButton extends ConsumerWidget {
  /// Creates a delete action button.
  const DeleteFriendshipButton({super.key, required this.friendship});

  /// Friendship row payload.
  final FriendshipListPageItemEntity friendship;

  /// Runs an optimistic friendship deletion through the notifier.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      deleteFriendshipMutationProvider(friendship.user.id),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(friendshipsListProvider.notifier)
          .removeFriendship(friendship);
    });
  }

  @override
  /// Builds the delete action button.
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> mutation = ref.watch(
      deleteFriendshipMutationProvider(friendship.user.id),
    );
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MIconButton.destructive(
      onPressed: () => _submit(ref),
      icon: LucideIcons.trash,
      dimension: 42.0,
    );
  }
}
