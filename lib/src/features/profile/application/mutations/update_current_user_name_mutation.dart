import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_current_user_name_mutation.g.dart';

/// Mutation: update the current user's name.
@riverpod
Mutation<void> updateCurrentUserNameMutation(Ref ref) {
  return Mutation<void>(label: 'update_current_user_name');
}
