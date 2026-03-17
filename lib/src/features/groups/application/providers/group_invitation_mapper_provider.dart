import 'package:memuno_app/src/features/groups/application/providers/group_mapper_provider.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_invitation_mapper.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_invitation_mapper_provider.g.dart';

/// Provides [GroupInvitationMapper].
@Riverpod(keepAlive: true)
GroupInvitationMapper groupInvitationMapper(Ref ref) {
  final GroupMapper groupMapper = ref.watch(groupMapperProvider);
  return GroupInvitationMapper(groupMapper: groupMapper);
}
