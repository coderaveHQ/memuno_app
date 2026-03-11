package dev.coderave.memuno_app.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Android app-widget receiver for the large meme widget entry.
 */
class MemeWidgetLargeReceiver : HomeWidgetGlanceWidgetReceiver<MemeWidgetGlanceWidget>() {
  /**
   * Returns the shared Glance widget implementation.
   */
  override val glanceAppWidget: MemeWidgetGlanceWidget = MemeWidgetGlanceWidget()
}
