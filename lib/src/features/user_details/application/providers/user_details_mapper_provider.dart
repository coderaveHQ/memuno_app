import 'package:memuno_app/src/features/user_details/data/mappers/user_details_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_mapper_provider.g.dart';

/// Provides the DTO-to-domain mapper for user-details data.
@Riverpod(keepAlive: true)
UserDetailsMapper userDetailsMapper(Ref ref) {
  return const UserDetailsMapper();
}
