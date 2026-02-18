import 'package:memuno_app/src/features/friendships/application/providers/friend_user_mapper_provider.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friend_user_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friendship_mapper_provider.g.dart';

/// Provides [FriendshipMapper].
@Riverpod(keepAlive: true)
FriendshipMapper friendshipMapper(Ref ref) {
  final FriendUserMapper friendUserMapper = ref.watch(friendUserMapperProvider);
  return FriendshipMapper(friendUserMapper: friendUserMapper);
}
