import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_email_mutation.g.dart';

/// Mutation: change email.
@riverpod
Mutation<void> changeEmailMutation(Ref ref) {
  return Mutation<void>(label: 'change_email');
}
