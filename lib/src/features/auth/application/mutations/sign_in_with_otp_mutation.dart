import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_with_otp_mutation.g.dart';

/// Mutation: sign in with OTP.
@riverpod
Mutation<void> signInWithOtpMutation(Ref ref) {
  // Mutation used by the UI to track loading/error state.
  return Mutation<void>(label: 'sign_in_with_otp');
}
