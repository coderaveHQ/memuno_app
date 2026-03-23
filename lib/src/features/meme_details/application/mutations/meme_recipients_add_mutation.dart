import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipients_add_mutation.g.dart';

/// Mutation: add one or more recipients from meme-details page.
@riverpod
Mutation<void> memeRecipientsAddMutation(Ref ref, String memeId) {
  return Mutation<void>(label: 'meme_recipients_add:$memeId');
}
