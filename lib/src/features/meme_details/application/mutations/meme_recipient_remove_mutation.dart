import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipient_remove_mutation.g.dart';

/// Mutation: remove one recipient target from meme-details page.
@riverpod
Mutation<bool> memeRecipientRemoveMutation(Ref ref, String mutationKey) {
  return Mutation<bool>(label: 'meme_recipient_remove:$mutationKey');
}
