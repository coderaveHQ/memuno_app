import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_meme_mutation.g.dart';

/// Mutation: report one meme from meme-details page.
@riverpod
Mutation<void> reportMemeMutation(Ref ref, String memeId) {
  return Mutation<void>(label: 'report_meme:$memeId');
}
