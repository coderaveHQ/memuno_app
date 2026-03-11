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

  @override
  Future<void> configure() async {
    await HomeWidget.setAppGroupId(AppEnv.widgetAppGroupId);
  }

  @override
  Future<void> saveSnapshot(MemeWidgetSnapshotEntity snapshot) {
    return HomeWidget.saveWidgetData<String>(
      _snapshotKey,
      jsonEncode(snapshot.toJson()),
    );
  }

  @override
  Future<MemeWidgetSnapshotEntity?> loadSnapshot() async {
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
  Future<void> clearSnapshot() {
    return HomeWidget.saveWidgetData<String>(_snapshotKey, '');
  }

  @override
  Future<void> savePendingActionUri(String actionUri) {
    return HomeWidget.saveWidgetData<String>(_pendingActionUriKey, actionUri);
  }

  @override
  Future<String?> takePendingActionUri() async {
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
    return HomeWidget.widgetClicked
        .where((Uri? uri) => uri != null)
        .cast<Uri>();
  }

  @override
  Future<Uri?> initiallyLaunchedUri() {
    return HomeWidget.initiallyLaunchedFromHomeWidget();
  }
}
