import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_user_details_meme_laugh_mutation.g.dart';

/// Mutation: toggle one user-details meme laugh by meme id.
@riverpod
Mutation<void> toggleUserDetailsMemeLaughMutation(Ref ref, String memeId) {
  return Mutation<void>(label: 'toggle_user_details_meme_laugh:$memeId');
}
