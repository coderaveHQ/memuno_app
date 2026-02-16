import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'validator_provider.g.dart';

/// Provides the input [Validator].
@Riverpod(keepAlive: true)
Validator validator(Ref ref) {
  // Stateless validator, safe to keep alive for the entire app.
  return const Validator();
}
