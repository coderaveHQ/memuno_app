import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/accept_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';

class AcceptFriendshipRequestButton extends ConsumerWidget {
  final FriendshipRequestEntity friendshipRequest;

  const AcceptFriendshipRequestButton({
    super.key,
    required this.friendshipRequest,
  });

  /// Runs optimistic acceptance for this incoming request.
  Future<void> _submit(WidgetRef ref) async {
    final Mutation<FriendshipEntity> mutation = ref.read(
      acceptFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      return ref
          .read(friendshipRequestsListProvider.notifier)
          .acceptRequest(friendshipRequest);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<FriendshipEntity> acceptMutation = ref.watch(
      acceptFriendshipRequestMutationProvider(friendshipRequest.id),
    );
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    ref.listen<MutationState<FriendshipEntity>>(acceptMutation, (prev, next) {
      if (next is MutationError<FriendshipEntity>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MIconButton.primary(
      onPressed: () => _submit(ref),
      icon: LucideIcons.check,
      dimension: 42.0,
    );
  }
}
