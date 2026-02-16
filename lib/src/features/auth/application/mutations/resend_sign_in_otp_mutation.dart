import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resend_sign_in_otp_mutation.g.dart';

/// Mutation: resend sign-in OTP.
@riverpod
Mutation<void> resendSignInOtpMutation(Ref ref) {
  return Mutation<void>(label: 'resend_sign_in_otp');
}
