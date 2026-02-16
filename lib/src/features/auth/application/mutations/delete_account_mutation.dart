import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_account_mutation.g.dart';

/// Mutation: delete account.
@riverpod
Mutation<void> deleteAccountMutation(Ref ref) {
  return Mutation<void>(label: 'delete_account');
}
