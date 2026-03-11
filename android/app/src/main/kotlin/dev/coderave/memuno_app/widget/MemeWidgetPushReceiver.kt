package dev.coderave.memuno_app.widget

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import java.io.File
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONArray
import org.json.JSONObject

/**
 * Native FCM receiver that updates HomeWidget snapshot state while app is closed.
 */
class MemeWidgetPushReceiver : BroadcastReceiver() {
  /**
   * Handles incoming FCM receive broadcasts and updates widget snapshot data.
   */
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action != fcmReceiveAction) {
      return
    }

    val pendingResult = goAsync()
    Thread {
      try {
        processPushIntent(context, intent)
      } finally {
        pendingResult.finish()
      }
    }.start()
  }

  private fun processPushIntent(context: Context, intent: Intent) {
    val extras = intent.extras ?: return
    val payload = extractPayload(extras)
    val delta = MemeWidgetPushDelta.parse(payload)

    if (!delta.isMemeNotification || !delta.isCompleteForWidget) {
      return
    }

    val preferences = context.getSharedPreferences(
        homeWidgetPreferencesName,
        Context.MODE_PRIVATE,
    )

    val rawSnapshot = preferences.getString(snapshotKey, null)
    val updatedSnapshot = MemeWidgetSnapshotJsonMerger.merge(
        context = context,
        rawSnapshot = rawSnapshot,
        delta = delta,
    )

    preferences.edit().putString(snapshotKey, updatedSnapshot).apply()
    triggerWidgetRefresh(context)
  }

  private fun extractPayload(extras: Bundle): Map<String, String> {
    val payload = mutableMapOf<String, String>()
    for (key in extras.keySet()) {
      val value = extras.get(key) ?: continue
      payload[key] = value.toString()
    }
    return payload
  }

  private fun triggerWidgetRefresh(context: Context) {
    val widgetManager = AppWidgetManager.getInstance(context)
    for (receiverClass in widgetReceiverClasses) {
      val component = ComponentName(context, receiverClass)
      val widgetIds = widgetManager.getAppWidgetIds(component)
      if (widgetIds.isEmpty()) {
        continue
      }

      val updateIntent = Intent(context, receiverClass).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
        putExtra(homeWidgetTriggeredFromWidgetExtra, true)
      }
      context.sendBroadcast(updateIntent)
    }
  }

  private companion object {
    const val fcmReceiveAction = "com.google.android.c2dm.intent.RECEIVE"
    const val snapshotKey = "meme_widget_snapshot"
    const val homeWidgetPreferencesName = "HomeWidgetPreferences"
    const val homeWidgetTriggeredFromWidgetExtra = "triggeredFromHomeWidget"
    val widgetReceiverClasses: List<Class<out BroadcastReceiver>> = listOf(
        MemeWidgetReceiver::class.java,
        MemeWidgetSmallReceiver::class.java,
        MemeWidgetLargeReceiver::class.java,
    )
  }
}

/**
 * Push metadata required for local widget upserts.
 */
private data class MemeWidgetPushDelta(
    val notificationType: String,
    val memeId: String?,
    val creatorId: String?,
    val creatorName: String?,
    val imagePathFull: String?,
    val imageUrlFull: String?,
    val aspectRatio: Double?,
    val laughCount: Int?,
    val isLaughed: Boolean?,
    val isOwnMeme: Boolean?,
) {
  /**
   * Returns true when the notification type belongs to meme flows.
   */
  val isMemeNotification: Boolean
    get() = notificationType == "meme_received" || notificationType == "meme_laughed"

  /**
   * Returns true when all required upsert fields are present.
   */
  val isCompleteForWidget: Boolean
    get() {
      return isMemeNotification &&
          memeId != null &&
          creatorId != null &&
          creatorName != null &&
          imagePathFull != null &&
          imageUrlFull != null &&
          aspectRatio != null &&
          laughCount != null &&
          isLaughed != null &&
          isOwnMeme != null
    }

  companion object {
    /**
     * Parses one push-delta model from FCM [payload].
     */
    fun parse(payload: Map<String, String>): MemeWidgetPushDelta {
      fun read(key: String): String? {
        val value = payload[key]?.trim()
        if (value.isNullOrEmpty()) {
          return null
        }
        return value
      }

      return MemeWidgetPushDelta(
          notificationType = read("notification_type") ?: "",
          memeId = read("widget_meme_id") ?: read("meme_id"),
          creatorId = read("widget_creator_id"),
          creatorName = read("widget_creator_name"),
          imagePathFull = read("widget_image_path_full"),
          imageUrlFull = read("widget_image_url_full"),
          aspectRatio = read("widget_aspect_ratio")?.toDoubleOrNull()?.takeIf { it > 0 },
          laughCount = read("widget_laugh_count")?.toIntOrNull()?.takeIf { it >= 0 },
          isLaughed = parseBool(read("widget_is_laughed")),
          isOwnMeme = parseBool(read("widget_is_own_meme")),
      )
    }

    private fun parseBool(rawValue: String?): Boolean? {
      if (rawValue == null) {
        return null
      }

      return when (rawValue.trim().lowercase()) {
        "true", "1", "yes" -> true
        "false", "0", "no" -> false
        else -> null
      }
    }
  }
}

/**
 * Merges push delta payloads into the persisted widget snapshot JSON.
 */
private object MemeWidgetSnapshotJsonMerger {
  private const val defaultBackgroundHex = "#191919"
  private const val defaultForegroundHex = "#FBFBFB"

  /**
   * Merges [delta] into [rawSnapshot] and returns serialized JSON.
   */
  fun merge(
      context: Context,
      rawSnapshot: String?,
      delta: MemeWidgetPushDelta,
  ): String {
    val root = parseRoot(rawSnapshot)
    val existingItems = root.optJSONArray("items") ?: JSONArray()
    val selectedMemeId = selectedMemeId(root, existingItems)

    val existingForDelta = findExistingItem(existingItems, delta.memeId!!)
    val isInsertedMeme = existingForDelta == null

    val nextItems = JSONArray()
    val cachedPath = resolveCachedImagePath(
        context = context,
        delta = delta,
        existing = existingForDelta,
    )

    nextItems.put(
        buildMergedItem(
            delta = delta,
            existing = existingForDelta,
            cachedPath = cachedPath,
        ),
    )

    for (index in 0 until existingItems.length()) {
      if (nextItems.length() >= maxItemCount) {
        break
      }

      val item = existingItems.optJSONObject(index) ?: continue
      val itemId = item.optString("memeId", "").trim()
      if (itemId.isEmpty() || itemId == delta.memeId) {
        continue
      }
      nextItems.put(item)
    }

    root.put("status", "ready")
    root.put("items", nextItems)
    root.put(
        "selectedIndex",
        if (isInsertedMeme) {
          0
        } else {
          resolveSelectedIndex(nextItems, selectedMemeId)
        },
    )
    val currentPendingLaughMemeId = root.optString("pendingLaughMemeId", "").trim()
    if (currentPendingLaughMemeId.isEmpty() || currentPendingLaughMemeId == delta.memeId) {
      root.put("pendingLaughMemeId", JSONObject.NULL)
    } else {
      root.put("pendingLaughMemeId", currentPendingLaughMemeId)
    }
    root.put("updatedAtEpochMs", System.currentTimeMillis())
    ensureText(root, "emptyText", "No memes, yet.")
    ensureText(root, "signedOutText", "Sign in to display memes.")
    ensureText(root, "laughActionText", "Laugh")
    ensureText(root, "unlaughActionText", "Unlaugh")
    ensureText(root, "ownerActionText", "Owner")

    return root.toString()
  }

  private fun parseRoot(rawSnapshot: String?): JSONObject {
    if (rawSnapshot.isNullOrBlank()) {
      return JSONObject()
    }

    return try {
      JSONObject(rawSnapshot)
    } catch (_error: Throwable) {
      JSONObject()
    }
  }

  private fun selectedMemeId(root: JSONObject, items: JSONArray): String? {
    if (items.length() <= 0) {
      return null
    }

    val selectedIndex = root.optInt("selectedIndex", 0).coerceIn(0, items.length() - 1)
    return items.optJSONObject(selectedIndex)
        ?.optString("memeId", "")
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
  }

  private fun findExistingItem(items: JSONArray, memeId: String): JSONObject? {
    for (index in 0 until items.length()) {
      val item = items.optJSONObject(index) ?: continue
      if (item.optString("memeId", "").trim() == memeId) {
        return item
      }
    }

    return null
  }

  private fun resolveCachedImagePath(
      context: Context,
      delta: MemeWidgetPushDelta,
      existing: JSONObject?,
  ): String? {
    val existingUrl = existing?.optString("imageUrlFull", "")?.trim()
    if (!existingUrl.isNullOrEmpty() && existingUrl == delta.imageUrlFull) {
      val cached = existing.optString("androidCachedImagePath", "").trim()
      if (cached.isNotEmpty()) {
        return cached
      }
    }

    return downloadAndCacheImage(
        context = context,
        memeId = delta.memeId!!,
        imageUrl = delta.imageUrlFull!!,
    )
  }

  private fun downloadAndCacheImage(
      context: Context,
      memeId: String,
      imageUrl: String,
  ): String? {
    var connection: HttpURLConnection? = null
    var stream: InputStream? = null

    return try {
      connection = (URL(imageUrl).openConnection() as? HttpURLConnection) ?: return null
      connection.instanceFollowRedirects = true
      connection.connectTimeout = connectTimeoutMs
      connection.readTimeout = readTimeoutMs
      connection.requestMethod = "GET"
      connection.connect()

      if (connection.responseCode !in 200..299) {
        return null
      }

      stream = connection.inputStream
      val bytes = stream.readBytes()
      if (bytes.isEmpty()) {
        return null
      }

      val file = File(context.cacheDir, "meme_widget_$memeId.bin")
      file.writeBytes(bytes)
      file.path
    } catch (_error: Throwable) {
      null
    } finally {
      try {
        stream?.close()
      } catch (_: Throwable) {
      }
      connection?.disconnect()
    }
  }

  private fun buildMergedItem(
      delta: MemeWidgetPushDelta,
      existing: JSONObject?,
      cachedPath: String?,
  ): JSONObject {
    val item = JSONObject()
    item.put("memeId", delta.memeId)
    item.put("creatorId", delta.creatorId)
    item.put("creatorName", delta.creatorName)
    item.put("laughCount", delta.laughCount)
    item.put("isLaughed", delta.isLaughed)
    item.put("isOwnMeme", delta.isOwnMeme)
    item.put("aspectRatio", delta.aspectRatio)
    item.put("imagePath", delta.imagePathFull)
    item.put("imageUrlFull", delta.imageUrlFull)

    if (cachedPath.isNullOrBlank()) {
      item.put("androidCachedImagePath", JSONObject.NULL)
    } else {
      item.put("androidCachedImagePath", cachedPath)
    }

    item.put(
        "backgroundHex",
        existing?.optString("backgroundHex", defaultBackgroundHex)?.takeIf { it.isNotBlank() }
            ?: defaultBackgroundHex,
    )
    item.put(
        "foregroundHex",
        existing?.optString("foregroundHex", defaultForegroundHex)?.takeIf { it.isNotBlank() }
            ?: defaultForegroundHex,
    )

    return item
  }

  private fun resolveSelectedIndex(items: JSONArray, selectedMemeId: String?): Int {
    if (items.length() <= 0 || selectedMemeId.isNullOrBlank()) {
      return 0
    }

    for (index in 0 until items.length()) {
      val id = items.optJSONObject(index)?.optString("memeId", "")?.trim()
      if (id == selectedMemeId) {
        return index
      }
    }

    return 0
  }

  private fun ensureText(root: JSONObject, key: String, fallback: String) {
    val value = root.optString(key, "").trim()
    if (value.isEmpty()) {
      root.put(key, fallback)
    }
  }

  private const val maxItemCount = 5
  private const val connectTimeoutMs = 6_000
  private const val readTimeoutMs = 8_000
}
