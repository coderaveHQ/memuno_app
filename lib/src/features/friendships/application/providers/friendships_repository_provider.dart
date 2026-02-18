import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_mapper_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_request_mapper_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_datasource_provider.dart';
import 'package:memuno_app/src/features/friendships/data/datasources/friendships_datasource.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_request_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/repositories/friendships_repository_impl.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friendships_repository_provider.g.dart';

/// Provides the friendships repository implementation.
@Riverpod(keepAlive: true)
FriendshipsRepository friendshipsRepository(Ref ref) {
  final FriendshipsDatasource friendshipsDatasource = ref.watch(
    friendshipsDatasourceProvider,
  );
  final FriendshipMapper friendshipMapper = ref.watch(friendshipMapperProvider);
  final FriendshipRequestMapper friendshipRequestMapper = ref.watch(
    friendshipRequestMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return FriendshipsRepositoryImpl(
    friendshipsDatasource: friendshipsDatasource,
    friendshipMapper: friendshipMapper,
    friendshipRequestMapper: friendshipRequestMapper,
    failureMapper: failureMapper,
  );
}
