import 'package:memuno_app/src/core/failures/failure.dart';

/// Maps arbitrary errors into domain [Failure] values.
abstract interface class FailureMapper {
  /// Converts an [error] object into a [Failure].
  Failure map(Object error);
}
