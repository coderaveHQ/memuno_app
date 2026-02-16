import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_mutation.g.dart';

/// Mutation: change password.
@riverpod
Mutation<void> changePasswordMutation(Ref ref) {
  return Mutation<void>(label: 'change_password');
}
