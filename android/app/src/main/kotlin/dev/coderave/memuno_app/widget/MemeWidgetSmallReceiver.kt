package dev.coderave.memuno_app.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Android app-widget receiver for the small meme widget entry.
 */
class MemeWidgetSmallReceiver : HomeWidgetGlanceWidgetReceiver<MemeWidgetGlanceWidget>() {
  /**
   * Returns the shared Glance widget implementation.
   */
  override val glanceAppWidget: MemeWidgetGlanceWidget = MemeWidgetGlanceWidget()
}
