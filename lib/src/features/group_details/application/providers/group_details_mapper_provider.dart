import 'package:memuno_app/src/features/group_details/data/mappers/group_details_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_mapper_provider.g.dart';

/// Provides the group-details mapper implementation.
@Riverpod(keepAlive: true)
GroupDetailsMapper groupDetailsMapper(Ref ref) {
  return const GroupDetailsMapper();
}
