import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resend_sign_up_otp_mutation.g.dart';

/// Mutation: resend sign-up OTP.
@riverpod
Mutation<void> resendSignUpOtpMutation(Ref ref) {
  return Mutation<void>(label: 'resend_sign_up_otp');
}
