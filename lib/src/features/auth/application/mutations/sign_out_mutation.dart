import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_mutation.g.dart';

/// Mutation: sign out.
@riverpod
Mutation<void> signOutMutation(Ref ref) {
  // Mutation used by the UI to track loading/error state.
  return Mutation<void>(label: 'sign_out');
}
