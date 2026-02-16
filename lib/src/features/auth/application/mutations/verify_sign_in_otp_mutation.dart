import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_sign_in_otp_mutation.g.dart';

/// Mutation: verify OTP.
@riverpod
Mutation<void> verifySignInOtpMutation(Ref ref) {
  // Mutation used by the UI to track loading/error state.
  return Mutation<void>(label: 'verify_sign_in_otp');
}
