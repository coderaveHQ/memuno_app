import 'package:memuno_app/src/features/friendships/data/mappers/friend_user_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friend_user_mapper_provider.g.dart';

/// Provides [FriendUserMapper].
@Riverpod(keepAlive: true)
FriendUserMapper friendUserMapper(Ref ref) {
  return const FriendUserMapper();
}
