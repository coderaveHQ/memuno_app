import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Image } from "https://deno.land/x/imagescript@1.3.0/mod.ts";
import { requireMachineApiKey } from "../_shared/auth.ts";
import {
  ENV_SECRET,
  getEnvByName,
  getRequiredSecret,
  type EnvReader,
} from "../_shared/env.ts";
import {
  createEdgeHandler,
  errorResponse,
  jsonResponse,
  parseJsonBody,
  requirePostMethod,
} from "../_shared/http.ts";
import { logEvent, toError } from "../_shared/logger.ts";
import { createSupabaseAdminClient } from "../_shared/supabase.ts";

type PushPreviewStatus = "pending" | "ready" | "failed";

type MemeRow = {
  id: string;
  imagePath: string;
  pushImagePath: string | null;
  pushPreviewStatus: PushPreviewStatus;
};

type HandlerDependencies = {
  createSupabaseAdminClient: (
    supabaseUrl: string,
    secretKey: string,
  ) => SupabaseClient;
  getEnv: EnvReader;
};

const ORIGINAL_MEMES_BUCKET = "memes";
const MEMES_PUSH_BUCKET = "memes_push";
const PUSH_PREVIEW_SUFFIX = "_push.jpg";
const PUSH_PREVIEW_MAX_BYTES = 950 * 1024;
const PUSH_PREVIEW_MAX_DIMENSION = 1440;
const PUSH_PREVIEW_MIN_DIMENSION = 320;
const PUSH_PREVIEW_RESIZE_FACTOR = 0.85;
const PUSH_PREVIEW_INITIAL_JPEG_QUALITY = 88;
const PUSH_PREVIEW_MIN_JPEG_QUALITY = 44;
const PUSH_PREVIEW_JPEG_QUALITY_STEP = 8;
const MAX_PREVIEW_PROCESS_ATTEMPTS = 2;

const defaultDependencies: HandlerDependencies = {
  createSupabaseAdminClient,
  getEnv: getEnvByName,
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function asString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function readRequiredString(
  record: Record<string, unknown>,
  key: string,
): string {
  const value = asString(record[key]);
  if (value == null) {
    throw new Error(`Missing or invalid string field: ${key}`);
  }
  return value;
}

function parsePushPreviewStatus(value: unknown): PushPreviewStatus {
  if (value === "pending" || value === "ready" || value === "failed") {
    return value;
  }
  throw new Error("Invalid push preview status in meme record.");
}

function parseMemeRow(payload: unknown): MemeRow {
  if (!isRecord(payload)) {
    throw new Error("Meme row payload must be an object.");
  }

  return {
    id: readRequiredString(payload, "id"),
    imagePath: readRequiredString(payload, "image_path"),
    pushImagePath: asString(payload["push_image_path"]),
    pushPreviewStatus: parsePushPreviewStatus(payload["push_preview_status"]),
  };
}

function extractMemeIdFromWebhookPayload(payload: unknown): string {
  if (!isRecord(payload)) {
    throw new Error("Webhook payload must be a JSON object.");
  }

  const record = isRecord(payload.record) ? payload.record : payload;
  return readRequiredString(record, "id");
}

function derivePushPreviewPath(imagePath: string): string {
  const normalizedImagePath = imagePath.trim();
  if (normalizedImagePath.length === 0) {
    throw new Error(
      "Cannot derive push preview path from an empty image path.",
    );
  }

  const lastSlashIndex = normalizedImagePath.lastIndexOf("/");
  const directory = lastSlashIndex >= 0
    ? normalizedImagePath.slice(0, lastSlashIndex + 1)
    : "";
  const filename = lastSlashIndex >= 0
    ? normalizedImagePath.slice(lastSlashIndex + 1)
    : normalizedImagePath;
  const extensionIndex = filename.lastIndexOf(".");
  const baseFilename = extensionIndex > 0
    ? filename.slice(0, extensionIndex)
    : filename;

  if (baseFilename.length === 0) {
    throw new Error(
      `Cannot derive push preview path from invalid filename: ${imagePath}`,
    );
  }

  return `${directory}${baseFilename}${PUSH_PREVIEW_SUFFIX}`;
}

async function loadMemeRow(
  supabase: SupabaseClient,
  memeId: string,
): Promise<MemeRow | null> {
  const { data, error } = await supabase
    .from("memes")
    .select("id, image_path, push_image_path, push_preview_status")
    .eq("id", memeId)
    .maybeSingle();

  if (error != null) {
    throw error;
  }

  if (data == null) {
    return null;
  }

  return parseMemeRow(data);
}

async function markMemePreviewReady(
  supabase: SupabaseClient,
  memeId: string,
  pushImagePath: string,
): Promise<boolean> {
  const { data, error } = await supabase
    .from("memes")
    .update({
      push_image_path: pushImagePath,
      push_preview_status: "ready",
    })
    .eq("id", memeId)
    .eq("push_preview_status", "pending")
    .select("id");

  if (error != null) {
    throw error;
  }

  return Array.isArray(data) && data.length > 0;
}

async function markMemePreviewFailed(
  supabase: SupabaseClient,
  memeId: string,
): Promise<boolean> {
  const { data, error } = await supabase
    .from("memes")
    .update({
      push_image_path: null,
      push_preview_status: "failed",
    })
    .eq("id", memeId)
    .eq("push_preview_status", "pending")
    .select("id");

  if (error != null) {
    throw error;
  }

  return Array.isArray(data) && data.length > 0;
}

async function downloadOriginalMemeBytes(
  supabase: SupabaseClient,
  imagePath: string,
): Promise<Uint8Array> {
  const { data, error } = await supabase.storage
    .from(ORIGINAL_MEMES_BUCKET)
    .download(imagePath);

  if (error != null) {
    throw error;
  }

  if (data == null) {
    throw new Error("Original meme image was not found.");
  }

  const bytes = new Uint8Array(await data.arrayBuffer());
  if (bytes.byteLength === 0) {
    throw new Error("Original meme image is empty.");
  }

  return bytes;
}

async function uploadPushPreviewBytes(
  supabase: SupabaseClient,
  pushImagePath: string,
  bytes: Uint8Array,
): Promise<void> {
  const { error } = await supabase.storage
    .from(MEMES_PUSH_BUCKET)
    .upload(pushImagePath, bytes, {
      contentType: "image/jpeg",
      upsert: true,
    });

  if (error != null) {
    throw error;
  }
}

function resizeToMaxDimension(image: Image): void {
  const longestEdge = Math.max(image.width, image.height);
  if (longestEdge <= PUSH_PREVIEW_MAX_DIMENSION) {
    return;
  }

  const scale = PUSH_PREVIEW_MAX_DIMENSION / longestEdge;
  const targetWidth = Math.max(Math.round(image.width * scale), 1);
  const targetHeight = Math.max(Math.round(image.height * scale), 1);
  image.resize(targetWidth, targetHeight);
}

async function encodePushPreviewBytes(
  sourceBytes: Uint8Array,
): Promise<Uint8Array> {
  const image = await Image.decode(sourceBytes);
  resizeToMaxDimension(image);

  let smallestAttempt: Uint8Array | null = null;

  while (true) {
    for (
      let quality = PUSH_PREVIEW_INITIAL_JPEG_QUALITY;
      quality >= PUSH_PREVIEW_MIN_JPEG_QUALITY;
      quality -= PUSH_PREVIEW_JPEG_QUALITY_STEP
    ) {
      const encoded = await image.encodeJPEG(quality);
      if (
        smallestAttempt == null ||
        encoded.byteLength < smallestAttempt.byteLength
      ) {
        smallestAttempt = encoded;
      }

      if (encoded.byteLength <= PUSH_PREVIEW_MAX_BYTES) {
        return encoded;
      }
    }

    if (
      image.width <= PUSH_PREVIEW_MIN_DIMENSION ||
      image.height <= PUSH_PREVIEW_MIN_DIMENSION
    ) {
      break;
    }

    const nextWidth = Math.max(
      Math.round(image.width * PUSH_PREVIEW_RESIZE_FACTOR),
      PUSH_PREVIEW_MIN_DIMENSION,
    );
    const nextHeight = Math.max(
      Math.round(image.height * PUSH_PREVIEW_RESIZE_FACTOR),
      PUSH_PREVIEW_MIN_DIMENSION,
    );

    if (nextWidth === image.width && nextHeight === image.height) {
      break;
    }

    image.resize(nextWidth, nextHeight);
  }

  if (smallestAttempt == null) {
    throw new Error("Could not encode push preview image.");
  }

  return smallestAttempt;
}

export function createGenerateMemePushPreviewHandler(
  overrides: Partial<HandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: HandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler(
    "generate_meme_push_preview",
    async (request: Request): Promise<Response> => {
      const methodError = requirePostMethod(request);
      if (methodError != null) {
        return methodError;
      }

      const authResult = requireMachineApiKey(request, deps.getEnv);
      if ("error" in authResult) {
        return authResult.error;
      }

      const parseResult = await parseJsonBody(request);
      if ("error" in parseResult) {
        return parseResult.error;
      }

      const payload = parseResult.payload;

      if (isRecord(payload)) {
        const eventType = asString(payload.type);
        if (eventType != null && eventType !== "INSERT") {
          logEvent("info", "generate_meme_push_preview.skipped", {
            reason: "unsupported_event_type",
            received_event_type: eventType,
          });
          return jsonResponse(200, {
            success: true,
            skipped: "unsupported_event_type",
          });
        }

        const table = asString(payload.table);
        if (table != null && table !== "memes") {
          logEvent("info", "generate_meme_push_preview.skipped", {
            reason: "unsupported_table",
            received_table: table,
          });
          return jsonResponse(200, {
            success: true,
            skipped: "unsupported_table",
          });
        }
      }

      let memeId: string;
      try {
        memeId = extractMemeIdFromWebhookPayload(payload);
      } catch (error) {
        return errorResponse(
          400,
          "invalid_payload",
          error instanceof Error
            ? error.message
            : "Could not parse webhook payload.",
        );
      }

      let supabaseUrl: string;
      let supabaseSecretKey: string;
      try {
        supabaseUrl = getRequiredSecret(ENV_SECRET.SUPABASE_URL, deps.getEnv);
        supabaseSecretKey = getRequiredSecret(
          ENV_SECRET.SB_SECRET_KEY,
          deps.getEnv,
        );
      } catch (_error) {
        return errorResponse(
          500,
          "missing_env",
          "SUPABASE_URL and SB_SECRET_KEY are required.",
        );
      }

      const supabase = deps.createSupabaseAdminClient(
        supabaseUrl,
        supabaseSecretKey,
      );

      let meme: MemeRow | null;
      try {
        meme = await loadMemeRow(supabase, memeId);
      } catch (error) {
        const resolved = toError(error);
        logEvent("error", "generate_meme_push_preview.meme_load_failed", {
          meme_id: memeId,
          error: resolved.message,
        });
        return errorResponse(500, "meme_load_failed", "Failed to load meme row.");
      }

      if (meme == null) {
        logEvent("info", "generate_meme_push_preview.skipped", {
          meme_id: memeId,
          reason: "meme_not_found",
        });
        return jsonResponse(200, { success: true, skipped: "meme_not_found" });
      }

      if (meme.pushPreviewStatus === "ready" && meme.pushImagePath != null) {
        logEvent("info", "generate_meme_push_preview.skipped", {
          meme_id: meme.id,
          reason: "already_ready",
          push_image_path: meme.pushImagePath,
        });
        return jsonResponse(200, { success: true, skipped: "already_ready" });
      }

      if (meme.pushPreviewStatus === "failed") {
        logEvent("info", "generate_meme_push_preview.skipped", {
          meme_id: meme.id,
          reason: "already_failed",
        });
        return jsonResponse(200, { success: true, skipped: "already_failed" });
      }

      if (meme.pushPreviewStatus !== "pending") {
        logEvent("info", "generate_meme_push_preview.skipped", {
          meme_id: meme.id,
          reason: "unsupported_status",
          push_preview_status: meme.pushPreviewStatus,
        });
        return jsonResponse(200, {
          success: true,
          skipped: "unsupported_status",
        });
      }

      let lastError: Error | null = null;

      for (
        let attempt = 1;
        attempt <= MAX_PREVIEW_PROCESS_ATTEMPTS;
        attempt += 1
      ) {
        try {
          const sourceBytes = await downloadOriginalMemeBytes(
            supabase,
            meme.imagePath,
          );
          const pushPreviewBytes = await encodePushPreviewBytes(sourceBytes);
          const pushImagePath = derivePushPreviewPath(meme.imagePath);

          await uploadPushPreviewBytes(
            supabase,
            pushImagePath,
            pushPreviewBytes,
          );

          const markedReady = await markMemePreviewReady(
            supabase,
            meme.id,
            pushImagePath,
          );

          if (!markedReady) {
            logEvent("info", "generate_meme_push_preview.skipped", {
              meme_id: meme.id,
              reason: "already_resolved",
              attempt,
            });
            return jsonResponse(200, {
              success: true,
              skipped: "already_resolved",
            });
          }

          logEvent("info", "generate_meme_push_preview.completed", {
            meme_id: meme.id,
            status: "ready",
            push_image_path: pushImagePath,
            bytes: pushPreviewBytes.byteLength,
            attempt,
          });

          return jsonResponse(200, {
            success: true,
            status: "ready",
            push_image_path: pushImagePath,
          });
        } catch (error) {
          lastError = toError(error);
          logEvent("warn", "generate_meme_push_preview.attempt_failed", {
            meme_id: meme.id,
            attempt,
            error: lastError.message,
          });
        }
      }

      try {
        const markedFailed = await markMemePreviewFailed(supabase, meme.id);
        if (!markedFailed) {
          logEvent("info", "generate_meme_push_preview.skipped", {
            meme_id: meme.id,
            reason: "already_resolved",
            phase: "mark_failed",
          });
          return jsonResponse(200, {
            success: true,
            skipped: "already_resolved",
          });
        }
      } catch (error) {
        const resolved = toError(error);
        logEvent("error", "generate_meme_push_preview.mark_failed_failed", {
          meme_id: meme.id,
          error: resolved.message,
        });
        return errorResponse(
          500,
          "mark_failed_failed",
          "Preview generation failed and meme status could not be updated.",
        );
      }

      logEvent("warn", "generate_meme_push_preview.completed", {
        meme_id: meme.id,
        status: "failed",
        error: lastError?.message ?? "unknown_error",
      });

      return jsonResponse(200, {
        success: true,
        status: "failed",
      });
    }
  );
}

if (import.meta.main) {
  Deno.serve(createGenerateMemePushPreviewHandler());
}
