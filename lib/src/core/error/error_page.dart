import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/core/providers/failure_message_resolver_provider.dart';

/// A generic error page for routing/unknown failures.
///
/// This widget is used as the `errorBuilder` output of GoRouter.
/// It must be stable and resilient because it is used when other
/// parts of the app fail.
final class ErrorPage extends ConsumerWidget {
  /// Creates an error page from an [Exception] produced by the router.
  const ErrorPage({super.key, required this.error});

  /// The error thrown by routing/build logic.
  final Exception error;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve a user-facing message from the error.
    final String message = _resolveMessage(context, ref, error);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  /// Resolves the most user-friendly message available.
  String _resolveMessage(BuildContext context, WidgetRef ref, Exception error) {
    final FailureMapper mapper = ref.watch(failureMapperProvider);
    final resolver = ref.watch(failureMessageResolverProvider);
    final Failure failure = mapper.map(error);
    return resolver.resolve(context, failure);
  }
}
