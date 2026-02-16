import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_locale_provider.g.dart';

/// Tracks the current system locale.
@Riverpod(keepAlive: true)
class SystemLocale extends _$SystemLocale {
  @override
  /// Builds and returns the widget tree for this component.
  Locale build() {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  /// Updates the tracked system locale.
  void update(Locale locale) {
    state = locale;
  }
}
