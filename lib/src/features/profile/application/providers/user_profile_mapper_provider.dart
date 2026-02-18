import 'package:memuno_app/src/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_mapper_provider.g.dart';

/// Provides the DTO-to-domain mapper for profile data.
@Riverpod(keepAlive: true)
UserProfileMapper userProfileMapper(Ref ref) {
  return const UserProfileMapper();
}
