import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'share_plus_provider.g.dart';

/// Provides the app-wide [SharePlus] instance.
@Riverpod(keepAlive: true)
SharePlus sharePlus(Ref ref) {
  return SharePlus.instance;
}
