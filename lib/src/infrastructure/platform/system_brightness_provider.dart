import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_brightness_provider.g.dart';

/// Tracks the current system brightness.
@Riverpod(keepAlive: true)
class SystemBrightness extends _$SystemBrightness {
  @override
  /// Builds and returns the widget tree for this component.
  Brightness build() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Updates the tracked system brightness.
  void update(Brightness brightness) {
    state = brightness;
  }
}
