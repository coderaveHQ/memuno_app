package dev.coderave.memuno_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    ensureDefaultNotificationChannel()
  }

  private fun ensureDefaultNotificationChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      return
    }

    val notificationManager = getSystemService(NotificationManager::class.java) ?: return
    val channel = NotificationChannel(
      DEFAULT_NOTIFICATION_CHANNEL_ID,
      "Memuno notifications",
      NotificationManager.IMPORTANCE_HIGH
    ).apply {
      description = "General notifications for the Memuno app."
    }
    notificationManager.createNotificationChannel(channel)
  }

  private companion object {
    const val DEFAULT_NOTIFICATION_CHANNEL_ID = "memuno_foreground_messages"
  }
}
