import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'send_meme_mutation.g.dart';

/// Mutation: send one finalized meme to selected recipients.
@riverpod
Mutation<void> sendMemeMutation(Ref ref) {
  return Mutation<void>(label: 'send_meme');
}
