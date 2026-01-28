import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

/// Riverpod provider for the app [Logger].
@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return Logger.instance;
}
