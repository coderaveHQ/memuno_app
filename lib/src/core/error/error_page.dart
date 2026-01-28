import 'package:flutter/material.dart';

/// A generic error page for routing/unknown failures.
///
/// This is shown by GoRouter when:
/// - a route builder throws
/// - an unknown exception happens during navigation
///
/// We keep this UI simple and stable (it should never crash itself).
final class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});

  final Exception error;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
