import 'package:memuno_app/src/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_user_mapper_provider.g.dart';

/// Provides the [AuthUserMapper].
@Riverpod(keepAlive: true)
AuthUserMapper authUserMapper(Ref ref) {
  // Stateless mapper, safe to keep alive for the entire app.
  return const AuthUserMapper();
}
