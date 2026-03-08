import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_meme_laugh_mutation.g.dart';

/// Mutation: toggle one meme laugh by meme id.
@riverpod
Mutation<void> toggleMemeLaughMutation(Ref ref, String memeId) {
  return Mutation<void>(label: 'toggle_meme_laugh:$memeId');
}
