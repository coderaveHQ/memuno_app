package dev.coderave.memuno_app.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * Android app-widget receiver for the meme widget.
 *
 * This receiver bridges Android AppWidget update events to Glance rendering.
 */
class MemeWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MemeWidgetGlanceWidget>() {
  /**
   * Returns the concrete Glance widget implementation.
   */
  override val glanceAppWidget: MemeWidgetGlanceWidget = MemeWidgetGlanceWidget()
}
