import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/failures/failure_message_resolver.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/core/providers/failure_message_resolver_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_feedback_provider.g.dart';

/// Provides the app-level [AppFeedback] helper.
@Riverpod(keepAlive: true)
AppFeedback appFeedback(Ref ref) {
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);
  final FailureMessageResolver failureMessageResolver = ref.watch(
    failureMessageResolverProvider,
  );
  return AppFeedback(
    failureMapper: failureMapper,
    failureMessageResolver: failureMessageResolver,
  );
}
