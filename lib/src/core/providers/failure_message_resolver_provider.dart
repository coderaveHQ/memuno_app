import 'package:memuno_app/src/core/failures/failure_message_resolver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'failure_message_resolver_provider.g.dart';

/// Provides the [FailureMessageResolver] instance.
@Riverpod(keepAlive: true)
FailureMessageResolver failureMessageResolver(Ref ref) {
  // Stateless resolver, safe to reuse across the app.
  return const FailureMessageResolver();
}
