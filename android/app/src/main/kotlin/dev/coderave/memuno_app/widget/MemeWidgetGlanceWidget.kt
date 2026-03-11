package dev.coderave.memuno_app.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import dev.coderave.memuno_app.MainActivity
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity
import org.json.JSONArray
import org.json.JSONObject

/**
 * Glance-based home-screen widget for meme previews and quick interactions.
 */
class MemeWidgetGlanceWidget : GlanceAppWidget() {
  /**
   * Uses HomeWidget shared preferences as Glance state backing store.
   */
  override val stateDefinition: HomeWidgetGlanceStateDefinition =
      HomeWidgetGlanceStateDefinition()

  /**
   * Enables responsive layouts for small/medium/large home screen slots.
   */
  override val sizeMode: SizeMode =
      SizeMode.Responsive(
          setOf(
              DpSize(120.dp, 120.dp),
              DpSize(240.dp, 120.dp),
              DpSize(240.dp, 240.dp),
              DpSize(300.dp, 300.dp),
          ),
      )

  /**
   * Builds the widget content from serialized snapshot state.
   */
  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent {
      Content(
          context = context,
          state = currentState(),
      )
    }
  }

  /**
   * Renders the root widget UI.
   */
  @Composable
  private fun Content(context: Context, state: HomeWidgetGlanceState) {
    val rawSnapshot = state.preferences.getString(Keys.snapshotKey, null)
    val snapshot = MemeWidgetSnapshotParser.parse(rawSnapshot)

    when (snapshot.status) {
      MemeWidgetStatus.signedOut -> Placeholder(
          text = snapshot.signedOutText,
          background = MemeWidgetPalette.gray900,
          foreground = MemeWidgetPalette.gray100,
          clickAction = actionStartActivity<MainActivity>(
              context = context,
              uri = MemeWidgetUris.openApp(),
          ),
      )
      MemeWidgetStatus.empty -> Placeholder(
          text = snapshot.emptyText,
          background = MemeWidgetPalette.gray900,
          foreground = MemeWidgetPalette.gray100,
          clickAction = actionStartActivity<MainActivity>(
              context = context,
              uri = MemeWidgetUris.openApp(),
          ),
      )
      MemeWidgetStatus.ready -> ReadyCard(
          context = context,
          snapshot = snapshot,
      )
    }
  }

  /**
   * Renders one centered placeholder view for signed-out/empty states.
   */
  @Composable
  private fun Placeholder(
      text: String,
      background: Color,
      foreground: Color,
      clickAction: androidx.glance.action.Action,
  ) {
    Box(
        modifier =
            GlanceModifier.fillMaxSize()
                .background(MemeWidgetPalette.provider(background))
                .clickable(onClick = clickAction)
                .padding(16.dp),
        contentAlignment = Alignment.Center,
    ) {
      Text(
          text = text,
          style =
              TextStyle(
                  color = MemeWidgetPalette.provider(foreground),
                  fontSize = 14.sp,
                  fontWeight = FontWeight.Medium,
                  textAlign = TextAlign.Center,
              ),
      )
    }
  }

  /**
   * Renders one selected meme card with overlaid metadata and controls.
   */
  @Composable
  private fun ReadyCard(
      context: Context,
      snapshot: MemeWidgetSnapshot,
  ) {
    val selected = snapshot.selectedItem
    if (selected == null) {
      Placeholder(
          text = snapshot.emptyText,
          background = MemeWidgetPalette.gray900,
          foreground = MemeWidgetPalette.gray100,
          clickAction = actionStartActivity<MainActivity>(
              context = context,
              uri = MemeWidgetUris.openApp(),
          ),
      )
      return
    }

    val background = MemeWidgetColorParser.parseOrFallback(
        hex = selected.backgroundHex,
        fallback = MemeWidgetPalette.gray900,
    )
    val foreground = MemeWidgetColorParser.parseOrFallback(
        hex = selected.foregroundHex,
        fallback = MemeWidgetPalette.gray100,
    )

    val openAction = actionStartActivity<MainActivity>(
        context = context,
        uri = MemeWidgetUris.openMeme(selected.memeId),
    )
    val isLaughPending = snapshot.pendingLaughMemeId == selected.memeId

    Box(
        modifier =
            GlanceModifier.fillMaxSize()
                .background(MemeWidgetPalette.provider(background))
                .clickable(onClick = openAction),
    ) {
      val bitmap = MemeWidgetImageDecoder.decodeFile(selected.androidCachedImagePath)
      if (bitmap != null) {
        Image(
            provider = ImageProvider(bitmap),
            contentDescription = null,
            contentScale = ContentScale.Fit,
            modifier =
                GlanceModifier.fillMaxSize().background(
                    MemeWidgetPalette.provider(background),
                ),
        )
      }

      Box(
          modifier = GlanceModifier.fillMaxSize().padding(10.dp),
      ) {
        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.TopStart,
        ) {
          Badge(
              text = selected.creatorName,
              background = MemeWidgetPalette.badgeBackground,
              foreground = foreground,
          )
        }

        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.TopEnd,
        ) {
          val laughClickAction = if (selected.isOwnMeme || isLaughPending) {
            null
          } else {
            actionRunCallback<MemeWidgetLaughActionCallback>(
                actionParametersOf(MemeWidgetLaughActionCallback.memeIdKey to selected.memeId),
            )
          }
          LaughChip(
              text = "😂 ${selected.laughCount}",
              isLiked = selected.isLaughed,
              isEnabled = laughClickAction != null,
              onClick = laughClickAction,
          )
        }

        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.CenterStart,
        ) {
          ActionButton(
              text = "<",
              foreground = foreground,
              modifier = GlanceModifier.padding(start = 6.dp),
              onClick = actionRunCallback<MemeWidgetPreviousActionCallback>(),
          )
        }

        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.CenterEnd,
        ) {
          ActionButton(
              text = ">",
              foreground = foreground,
              modifier = GlanceModifier.padding(end = 6.dp),
              onClick = actionRunCallback<MemeWidgetNextActionCallback>(),
          )
        }
      }
    }
  }

  /**
   * Renders one pill badge.
   */
  @Composable
  private fun Badge(
      text: String,
      background: Color,
      foreground: Color,
  ) {
    Box(
        modifier =
            GlanceModifier.background(
                    MemeWidgetPalette.provider(background),
                )
                .cornerRadius(16.dp)
                .padding(horizontal = 7.dp, vertical = 4.dp),
    ) {
      Text(
          text = text,
          maxLines = 1,
          style =
              TextStyle(
                  color = MemeWidgetPalette.provider(foreground),
                  fontSize = 11.sp,
                  fontWeight = FontWeight.Medium,
              ),
      )
    }
  }

  /**
   * Renders one interactive laugh chip using feed-like colors and emoji/counter.
   */
  @Composable
  private fun LaughChip(
      text: String,
      isLiked: Boolean,
      isEnabled: Boolean,
      onClick: androidx.glance.action.Action?,
  ) {
    val background = if (isLiked) {
      MemeWidgetPalette.laughSelectedBackground
    } else {
      MemeWidgetPalette.laughUnselectedBackground
    }
    val foreground = if (isLiked) {
      MemeWidgetPalette.laughSelectedForeground
    } else {
      MemeWidgetPalette.laughUnselectedForeground
    }

    var modifier =
        GlanceModifier.background(MemeWidgetPalette.provider(background))
            .cornerRadius(20.dp)
            .padding(horizontal = 10.dp, vertical = 6.dp)

    if (isEnabled && onClick != null) {
      modifier = modifier.clickable(onClick = onClick)
    }

    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center,
    ) {
      Text(
          text = text,
          maxLines = 1,
          style =
              TextStyle(
                  color = MemeWidgetPalette.provider(foreground),
                  fontSize = 12.sp,
                  fontWeight = FontWeight.Bold,
                  textAlign = TextAlign.Center,
              ),
      )
    }
  }

  /**
   * Renders one compact interactive action button.
   */
  @Composable
  private fun ActionButton(
      text: String,
      foreground: Color,
      modifier: GlanceModifier = GlanceModifier,
      onClick: androidx.glance.action.Action,
  ) {
    Box(
        modifier =
            modifier
                .background(
                    MemeWidgetPalette.provider(MemeWidgetPalette.badgeBackground),
                )
                .cornerRadius(22.dp)
                .clickable(onClick = onClick)
                .padding(horizontal = 14.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center,
    ) {
      Text(
          text = text,
          maxLines = 1,
          style =
              TextStyle(
                  color = MemeWidgetPalette.provider(foreground),
                  fontSize = 14.sp,
                  fontWeight = FontWeight.Bold,
                  textAlign = TextAlign.Center,
              ),
      )
    }
  }

  /**
   * Widget data-store keys.
   */
  private object Keys {
    /**
     * Shared-preferences key that stores the serialized widget snapshot JSON.
     */
    const val snapshotKey: String = "meme_widget_snapshot"
  }
}

/**
 * Action callback for dispatching laugh toggles to Dart background handlers.
 */
class MemeWidgetLaughActionCallback : ActionCallback {
  /**
   * Sends a background HomeWidget intent with meme-id payload.
   */
  override suspend fun onAction(
      context: Context,
      glanceId: GlanceId,
      parameters: ActionParameters,
  ) {
    val memeId = parameters[memeIdKey] ?: return
    val intent = HomeWidgetBackgroundIntent.getBroadcast(
        context,
        MemeWidgetUris.laugh(memeId),
    )
    intent.send()
  }

  companion object {
    /**
     * Parameter key used to pass the current meme identifier into callback actions.
     */
    val memeIdKey = ActionParameters.Key<String>("meme_id")
  }
}

/**
 * Action callback for selecting previous meme in pager mode.
 */
class MemeWidgetPreviousActionCallback : ActionCallback {
  /**
   * Sends a background HomeWidget intent that selects previous item.
   */
  override suspend fun onAction(
      context: Context,
      glanceId: GlanceId,
      parameters: ActionParameters,
  ) {
    HomeWidgetBackgroundIntent.getBroadcast(
            context,
            MemeWidgetUris.previous(),
        )
        .send()
  }
}

/**
 * Action callback for selecting next meme in pager mode.
 */
class MemeWidgetNextActionCallback : ActionCallback {
  /**
   * Sends a background HomeWidget intent that selects next item.
   */
  override suspend fun onAction(
      context: Context,
      glanceId: GlanceId,
      parameters: ActionParameters,
  ) {
    HomeWidgetBackgroundIntent.getBroadcast(
            context,
            MemeWidgetUris.next(),
        )
        .send()
  }
}

/**
 * Snapshot status variants persisted by Flutter.
 */
private enum class MemeWidgetStatus {
  signedOut,
  empty,
  ready,
}

/**
 * Parsed snapshot model consumed by Android widget rendering.
 */
private data class MemeWidgetSnapshot(
    val status: MemeWidgetStatus,
    val items: List<MemeWidgetItem>,
    val selectedIndex: Int,
    val pendingLaughMemeId: String?,
    val emptyText: String,
    val signedOutText: String,
    val laughActionText: String,
    val unlaughActionText: String,
    val ownerActionText: String,
) {
  /**
   * Returns currently selected item, if available.
   */
  val selectedItem: MemeWidgetItem?
    get() {
      if (items.isEmpty()) {
        return null
      }

      val safeIndex = selectedIndex.coerceIn(0, items.lastIndex)
      return items[safeIndex]
    }
}

/**
 * Parsed item model consumed by Android widget rendering.
 */
private data class MemeWidgetItem(
    val memeId: String,
    val creatorName: String,
    val laughCount: Int,
    val isLaughed: Boolean,
    val isOwnMeme: Boolean,
    val androidCachedImagePath: String,
    val backgroundHex: String,
    val foregroundHex: String,
)

/**
 * Parses JSON snapshot payloads generated by Flutter.
 */
private object MemeWidgetSnapshotParser {
  /**
   * Parses [rawSnapshot] and returns a safe snapshot model with fallbacks.
   */
  fun parse(rawSnapshot: String?): MemeWidgetSnapshot {
    if (rawSnapshot.isNullOrBlank()) {
      return fallbackSnapshot(status = MemeWidgetStatus.signedOut)
    }

    return try {
      val root = JSONObject(rawSnapshot)
      val items = parseItems(root.optJSONArray("items"))
      val selectedIndex = root.optInt("selectedIndex", 0).coerceIn(
          minimumValue = 0,
          maximumValue = (items.lastIndex).coerceAtLeast(0),
      )

      MemeWidgetSnapshot(
          status = parseStatus(root.optString("status")),
          items = items,
          selectedIndex = selectedIndex,
          pendingLaughMemeId =
              root.optString("pendingLaughMemeId", "").trim().ifEmpty { null },
          emptyText = root.optString("emptyText", "No memes, yet."),
          signedOutText = root.optString("signedOutText", "Sign in to display memes."),
          laughActionText = root.optString("laughActionText", "Laugh"),
          unlaughActionText = root.optString("unlaughActionText", "Unlaugh"),
          ownerActionText = root.optString("ownerActionText", "Owner"),
      )
    } catch (_error: Throwable) {
      fallbackSnapshot(status = MemeWidgetStatus.empty)
    }
  }

  /**
   * Builds one fallback snapshot for unavailable or malformed payloads.
   */
  private fun fallbackSnapshot(status: MemeWidgetStatus): MemeWidgetSnapshot {
    return MemeWidgetSnapshot(
        status = status,
        items = emptyList(),
        selectedIndex = 0,
        pendingLaughMemeId = null,
        emptyText = "No memes, yet.",
        signedOutText = "Sign in to display memes.",
        laughActionText = "Laugh",
        unlaughActionText = "Unlaugh",
        ownerActionText = "Owner",
    )
  }

  /**
   * Parses snapshot status values with tolerant fallback handling.
   */
  private fun parseStatus(rawStatus: String): MemeWidgetStatus {
    return when (rawStatus) {
      "signedOut",
      "signed_out",
      -> MemeWidgetStatus.signedOut
      "ready" -> MemeWidgetStatus.ready
      else -> MemeWidgetStatus.empty
    }
  }

  /**
   * Parses item-array payloads from JSON.
   */
  private fun parseItems(itemsArray: JSONArray?): List<MemeWidgetItem> {
    if (itemsArray == null) {
      return emptyList()
    }

    val parsed = mutableListOf<MemeWidgetItem>()
    for (index in 0 until itemsArray.length()) {
      val itemObject = itemsArray.optJSONObject(index) ?: continue
      val memeId = itemObject.optString("memeId", "").trim()
      if (memeId.isEmpty()) {
        continue
      }

      parsed.add(
          MemeWidgetItem(
              memeId = memeId,
              creatorName = itemObject.optString("creatorName", ""),
              laughCount = itemObject.optInt("laughCount", 0).coerceAtLeast(0),
              isLaughed = itemObject.optBoolean("isLaughed", false),
              isOwnMeme = itemObject.optBoolean("isOwnMeme", false),
              androidCachedImagePath = itemObject.optString("androidCachedImagePath", ""),
              backgroundHex = itemObject.optString("backgroundHex", "#191919"),
              foregroundHex = itemObject.optString("foregroundHex", "#FBFBFB"),
          ),
      )
    }

    return parsed
  }
}

/**
 * Builds widget action URIs consumed by Flutter intent handling.
 */
private object MemeWidgetUris {
  /**
   * Creates URI for opening the app root.
   */
  fun openApp(): Uri = Uri.parse("memuno://meme-widget?action=open_app")

  /**
   * Creates URI for opening one meme details route.
   */
  fun openMeme(memeId: String): Uri {
    val encodedId = Uri.encode(memeId)
    return Uri.parse("memuno://meme-widget?action=open_meme&memeId=$encodedId")
  }

  /**
   * Creates URI for toggling one meme laugh state.
   */
  fun laugh(memeId: String): Uri {
    val encodedId = Uri.encode(memeId)
    return Uri.parse("memuno://meme-widget?action=laugh&memeId=$encodedId")
  }

  /**
   * Creates URI for selecting previous pager item.
   */
  fun previous(): Uri = Uri.parse("memuno://meme-widget?action=prev")

  /**
   * Creates URI for selecting next pager item.
   */
  fun next(): Uri = Uri.parse("memuno://meme-widget?action=next")
}

/**
 * Converts hexadecimal color strings to widget-safe colors.
 */
private object MemeWidgetColorParser {
  /**
   * Parses [hex] in `#RRGGBB` format, returning [fallback] when parsing fails.
   */
  fun parseOrFallback(hex: String, fallback: Color): Color {
    return try {
      Color(android.graphics.Color.parseColor(hex))
    } catch (_error: Throwable) {
      fallback
    }
  }
}

/**
 * Decodes widget images with downsampling to avoid host rendering failures.
 */
private object MemeWidgetImageDecoder {
  /**
   * Maximum dimension used while decoding file-backed images.
   */
  private const val maxDimensionPx = 1024

  /**
   * Decodes one [path] into a safely downsampled bitmap.
   */
  fun decodeFile(path: String): Bitmap? {
    if (path.isBlank()) {
      return null
    }

    return try {
      val bounds = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
      }
      BitmapFactory.decodeFile(path, bounds)

      if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
        return null
      }

      val sampleSize = calculateInSampleSize(bounds.outWidth, bounds.outHeight)
      val decodeOptions = BitmapFactory.Options().apply {
        inPreferredConfig = Bitmap.Config.RGB_565
        inSampleSize = sampleSize
      }

      BitmapFactory.decodeFile(path, decodeOptions)
    } catch (_error: Throwable) {
      null
    }
  }

  /**
   * Computes in-sample-size for [width] and [height].
   */
  private fun calculateInSampleSize(width: Int, height: Int): Int {
    var sampleSize = 1
    while ((width / sampleSize) > maxDimensionPx || (height / sampleSize) > maxDimensionPx) {
      sampleSize *= 2
    }
    return sampleSize.coerceAtLeast(1)
  }
}

/**
 * Static widget color palette aligned with the app design system.
 */
private object MemeWidgetPalette {
  /**
   * App-equivalent `MColors.gray900`.
   */
  val gray900: Color = Color(0xFF191919)

  /**
   * App-equivalent `MColors.gray100`.
   */
  val gray100: Color = Color(0xFFFBFBFB)

  /**
   * Badge background color.
   */
  val badgeBackground: Color = Color(0x5A000000)

  /**
   * Badge text color.
   */
  val badgeForeground: Color = Color(0xFFFFFFFF)

  /**
   * Feed-like laugh chip selected background.
   */
  val laughSelectedBackground: Color = Color(0x1AF6E05E)

  /**
   * Feed-like laugh chip selected foreground.
   */
  val laughSelectedForeground: Color = Color(0xFFF6E05E)

  /**
   * Feed-like laugh chip default background.
   */
  val laughUnselectedBackground: Color = Color(0xFFFBFBFB)

  /**
   * Feed-like laugh chip default foreground.
   */
  val laughUnselectedForeground: Color = Color(0xFF191919)

  /**
   * Creates one glance [ColorProvider] with identical day/night colors.
   */
  fun provider(color: Color): ColorProvider {
    return ColorProvider(color)
  }
}
