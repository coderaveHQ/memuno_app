import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/cancel_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';

class CancelFriendshipRequestButton extends ConsumerWidget {
  final FriendshipRequestListPageItemEntity friendshipRequest;
  const CancelFriendshipRequestButton({
    super.key,
    required this.friendshipRequest,
  });

  /// Runs optimistic cancel for this outgoing request.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      cancelFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(friendshipRequestsListProvider.notifier)
          .cancelRequest(friendshipRequest);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> cancelMutation = ref.watch(
      cancelFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    ref.listen<MutationState<void>>(cancelMutation, (prev, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MIconButton.secondary(
      onPressed: () => _submit(ref),
      icon: LucideIcons.x,
      dimension: 42.0,
    );
  }
}
