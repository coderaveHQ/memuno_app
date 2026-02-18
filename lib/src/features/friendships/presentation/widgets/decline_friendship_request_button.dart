import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/decline_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';

class DeclineFriendshipRequestButton extends ConsumerWidget {
  final FriendshipRequestEntity friendshipRequest;
  const DeclineFriendshipRequestButton({
    super.key,
    required this.friendshipRequest,
  });

  /// Runs optimistic decline for this incoming request.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      declineFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(friendshipRequestsListProvider.notifier)
          .declineRequest(friendshipRequest);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> declineMutation = ref.watch(
      declineFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    ref.listen<MutationState<void>>(declineMutation, (prev, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MIconButton.primary(
      onPressed: () => _submit(ref),
      icon: LucideIcons.x,
      dimension: 42.0,
    );
  }
}
