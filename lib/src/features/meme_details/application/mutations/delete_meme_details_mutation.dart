import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_meme_details_mutation.g.dart';

/// Mutation: delete one meme from meme-details page.
@riverpod
Mutation<void> deleteMemeDetailsMutation(Ref ref, String memeId) {
  return Mutation<void>(label: 'delete_meme_details:$memeId');
}
