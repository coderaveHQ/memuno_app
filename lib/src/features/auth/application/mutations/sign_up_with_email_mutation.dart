import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_with_email_mutation.g.dart';

/// Mutation: sign up with email.
@riverpod
Mutation<void> signUpWithEmailMutation(Ref ref) {
  // Mutation used by the UI to track loading/error state.
  return Mutation<void>(label: 'sign_up_with_email');
}
