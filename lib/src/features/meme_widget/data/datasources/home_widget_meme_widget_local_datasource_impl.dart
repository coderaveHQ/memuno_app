import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_local_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';

/// HomeWidget-backed implementation of [MemeWidgetLocalDatasource].
final class HomeWidgetMemeWidgetLocalDatasourceImpl
    implements MemeWidgetLocalDatasource {
  /// Creates the datasource.
  const HomeWidgetMemeWidgetLocalDatasourceImpl();

  static const String _snapshotKey = 'meme_widget_snapshot';
  static const String _pendingActionUriKey = 'meme_widget_pending_action_uri';
  static bool _isConfigured = false;
  static Future<void>? _configureInFlight;

  @override
  Future<void> configure() async {
    await _ensureConfigured();
  }

  @override
  Future<void> saveSnapshot(MemeWidgetSnapshotEntity snapshot) async {
    await _ensureConfigured();
    await HomeWidget.saveWidgetData<String>(
      _snapshotKey,
      jsonEncode(snapshot.toJson()),
    );
  }

  @override
  Future<MemeWidgetSnapshotEntity?> loadSnapshot() async {
    await _ensureConfigured();
    final String? rawValue = await HomeWidget.getWidgetData<String>(
      _snapshotKey,
    );
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }
      return MemeWidgetSnapshotEntity.fromJson(
        Map<String, Object?>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSnapshot() async {
    await _ensureConfigured();
    await HomeWidget.saveWidgetData<String>(_snapshotKey, '');
  }

  @override
  Future<void> savePendingActionUri(String actionUri) async {
    await _ensureConfigured();
    await HomeWidget.saveWidgetData<String>(_pendingActionUriKey, actionUri);
  }

  @override
  Future<String?> takePendingActionUri() async {
    await _ensureConfigured();
    final String? value = await HomeWidget.getWidgetData<String>(
      _pendingActionUriKey,
    );

    await HomeWidget.saveWidgetData<String>(_pendingActionUriKey, '');

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  @override
  Future<void> refreshNativeWidget() async {
    await _ensureConfigured();
    final List<Future<bool?>> updates = <Future<bool?>>[
      for (
        int index = 0;
        index < AppEnv.androidWidgetProviderNames.length;
        index += 1
      )
        HomeWidget.updateWidget(
          name: AppEnv.androidWidgetProviderNames[index],
          iOSName: AppEnv.iosWidgetKind,
          qualifiedAndroidName:
              AppEnv.androidWidgetQualifiedProviderNames[index],
        ),
    ];

    await Future.wait(updates);
  }

  @override
  Stream<Uri> widgetClickedStream() {
    return _widgetClickedStream();
  }

  Stream<Uri> _widgetClickedStream() async* {
    await _ensureConfigured();
    yield* HomeWidget.widgetClicked
        .where((Uri? uri) => uri != null)
        .cast<Uri>();
  }

  @override
  Future<Uri?> initiallyLaunchedUri() async {
    await _ensureConfigured();
    return HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  Future<void> _ensureConfigured() async {
    if (_isConfigured) {
      return;
    }
    final Future<void>? inFlight = _configureInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Future<void> configureFuture =
        HomeWidget.setAppGroupId(AppEnv.widgetAppGroupId)
            .then((_) {
              _isConfigured = true;
            })
            .whenComplete(() {
              _configureInFlight = null;
            });
    _configureInFlight = configureFuture;
    await configureFuture;
  }
}
