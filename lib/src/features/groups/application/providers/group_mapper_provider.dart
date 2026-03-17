import 'package:memuno_app/src/features/groups/data/mappers/group_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_mapper_provider.g.dart';

/// Provides [GroupMapper].
@Riverpod(keepAlive: true)
GroupMapper groupMapper(Ref ref) {
  return const GroupMapper();
}
