import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create_mutation.g.dart';

/// Mutation: create one group.
@riverpod
Mutation<GroupItemEntity> groupCreateMutation(Ref ref) {
  return Mutation<GroupItemEntity>(label: 'group_create');
}
