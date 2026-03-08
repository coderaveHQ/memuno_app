import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
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
import { logEvent } from "../_shared/logger.ts";
import { createSupabaseAdminClient } from "../_shared/supabase.ts";

type NotificationType =
  | "friendship_request_sent"
  | "friendship_request_accepted"
  | "meme_received"
  | "meme_laughed";

type NotificationRecord = {
  id: string;
  recipientId: string;
  type: NotificationType;
  data: Record<string, unknown>;
};

type PushDeviceTokenRow = {
  id: string;
  fcm_token: string;
  language_code: string | null;
  country_code: string | null;
};

type FirebaseServiceAccount = {
  client_email: string;
  private_key: string;
  project_id: string;
  token_uri: string;
};

type NotificationPushTemplate = {
  languageCode: string;
  countryCode: string | null;
  title: string | null;
  message: string;
};

type HandlerDependencies = {
  createSupabaseAdminClient: (
    supabaseUrl: string,
    secretKey: string,
  ) => SupabaseClient;
  fetchFn: typeof fetch;
  now: () => Date;
  getEnv: EnvReader;
};

export const MEMES_PUSH_BUCKET = "memes_push";
export const PUSH_IMAGE_SIGNED_URL_TTL_SECONDS = 604800;
export const PUSH_IMAGE_PUBLIC_BASE_URL_ENV_KEY =
  ENV_SECRET.PUSH_IMAGE_PUBLIC_BASE_URL;

type PushImageUrlSource =
  | "signed_url_absolute"
  | "public_base_url"
  | "supabase_url";

type ResolvedPushImageUrl = {
  url: string;
  protocol: string;
  host: string;
  hostname: string;
  source: PushImageUrlSource;
};

const defaultDependencies: HandlerDependencies = {
  createSupabaseAdminClient,
  fetchFn: fetch,
  now: () => new Date(),
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

function normalizeMultilinePrivateKey(privateKey: string): string {
  return privateKey.replace(/\\n/g, "\n");
}

function parseNotificationType(raw: string): NotificationType {
  if (
    raw !== "friendship_request_sent" &&
    raw !== "friendship_request_accepted" &&
    raw !== "meme_received" &&
    raw !== "meme_laughed"
  ) {
    throw new Error(`Unsupported notification type: ${raw}`);
  }

  return raw;
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

function readDataPayload(
  record: Record<string, unknown>,
): Record<string, unknown> {
  const data = record["data"];
  if (!isRecord(data)) {
    throw new Error("Missing or invalid notification data payload.");
  }

  return data;
}

export function parseNotificationRecord(payload: unknown): NotificationRecord {
  if (!isRecord(payload)) {
    throw new Error("Webhook payload must be a JSON object.");
  }

  const record = isRecord(payload.record) ? payload.record : payload;

  const notificationId = readRequiredString(record, "id");
  const recipientId = readRequiredString(record, "recipient_id");
  const type = parseNotificationType(readRequiredString(record, "type"));
  const data = readDataPayload(record);

  return {
    id: notificationId,
    recipientId,
    type,
    data,
  };
}

export function normalizeNotificationLanguage(
  languageCode: string | null | undefined,
): string {
  const normalized = asString(languageCode)?.toLowerCase();
  if (normalized == null) {
    return "en";
  }

  if (/^[a-z]{2}$/.test(normalized)) {
    return normalized;
  }

  if (normalized.startsWith("de")) {
    return "de";
  }

  if (normalized.startsWith("en")) {
    return "en";
  }

  return "en";
}

export function normalizeNotificationCountry(
  countryCode: string | null | undefined,
): string | null {
  const normalized = asString(countryCode)?.toUpperCase();
  if (normalized == null || !/^[A-Z]{2}$/.test(normalized)) {
    return null;
  }
  return normalized;
}

function sanitizeSenderName(
  senderNameValue: unknown,
  languageCode: string,
): string {
  const senderName = asString(senderNameValue);
  if (senderName != null) {
    return senderName;
  }

  return languageCode === "de" ? "Jemand" : "Someone";
}

export function buildNotificationTemplateVariables(
  notification: NotificationRecord,
  languageCode: string,
): Record<string, string> {
  const variables = buildNotificationDataPayload(notification);
  const senderName = sanitizeSenderName(
    notification.data["actor_name"],
    languageCode,
  );

  if (
    variables["actor_name"] == null || variables["actor_name"].trim() === ""
  ) {
    variables["actor_name"] = senderName;
  }
  variables["sender_name"] = senderName;

  return variables;
}

export function renderTemplateText(
  template: string,
  variables: Record<string, string>,
): string {
  return template.replace(/\{([a-zA-Z0-9_]+)\}/g, (_match, key: string) => {
    return variables[key] ?? "";
  });
}

async function findNotificationPushTemplate(
  supabase: SupabaseClient,
  notificationType: NotificationType,
  languageCode: string,
  countryCode: string | null,
): Promise<NotificationPushTemplate | null> {
  let query = supabase
    .from("notification_push_templates")
    .select("title, message")
    .eq("notification_type", notificationType)
    .eq("language_code", languageCode)
    .limit(1);

  if (countryCode == null) {
    query = query.is("country_code", null);
  } else {
    query = query.eq("country_code", countryCode);
  }

  const { data, error } = await query;
  if (error != null) {
    throw error;
  }

  const row = Array.isArray(data) ? data[0] : null;
  if (!isRecord(row)) {
    return null;
  }

  const message = asString(row.message);
  if (message == null) {
    throw new Error(
      "notification_push_templates.message must be a non-empty string.",
    );
  }

  return {
    languageCode,
    countryCode,
    title: asString(row.title),
    message,
  };
}

export async function resolveNotificationPushTemplate(
  supabase: SupabaseClient,
  notificationType: NotificationType,
  languageCodeRaw: string | null | undefined,
  countryCodeRaw: string | null | undefined,
): Promise<NotificationPushTemplate> {
  const languageCode = normalizeNotificationLanguage(languageCodeRaw);
  const countryCode = normalizeNotificationCountry(countryCodeRaw);

  const candidates: Array<
    { languageCode: string; countryCode: string | null }
  > = [];

  if (countryCode != null) {
    candidates.push({ languageCode, countryCode });
  }
  candidates.push({ languageCode, countryCode: null });

  if (languageCode !== "en") {
    if (countryCode != null) {
      candidates.push({ languageCode: "en", countryCode });
    }
    candidates.push({ languageCode: "en", countryCode: null });
  }

  for (const candidate of candidates) {
    const template = await findNotificationPushTemplate(
      supabase,
      notificationType,
      candidate.languageCode,
      candidate.countryCode,
    );
    if (template != null) {
      return template;
    }
  }

  throw new Error(
    `No push template found for notification_type=${notificationType}, language_code=${languageCode}, country_code=${
      countryCode ?? "null"
    }.`,
  );
}

export function buildNotificationDataPayload(
  notification: NotificationRecord,
): Record<string, string> {
  const payload: Record<string, string> = {
    notification_id: notification.id,
    notification_type: notification.type,
  };

  for (const [key, value] of Object.entries(notification.data)) {
    if (typeof value === "string") {
      payload[key] = value;
      continue;
    }

    if (typeof value === "number" || typeof value === "boolean") {
      payload[key] = String(value);
    }
  }

  return payload;
}

export function normalizeSignedUrl(
  signedUrl: string,
  supabaseUrl: string,
): string {
  return resolvePushImageUrl(signedUrl, supabaseUrl, null).url;
}

function parseUrl(value: string, context: string): URL {
  try {
    return new URL(value);
  } catch (_error) {
    throw new Error(`${context} must be a valid URL.`);
  }
}

function tryParseAbsoluteUrl(value: string): URL | null {
  try {
    return new URL(value);
  } catch (_error) {
    return null;
  }
}

export function resolvePushImageUrl(
  signedUrl: string,
  supabaseUrl: string,
  pushImagePublicBaseUrl: string | null,
): ResolvedPushImageUrl {
  const absoluteSignedUrl = tryParseAbsoluteUrl(signedUrl);
  if (absoluteSignedUrl != null) {
    if (pushImagePublicBaseUrl == null) {
      return {
        url: absoluteSignedUrl.toString(),
        protocol: absoluteSignedUrl.protocol,
        host: absoluteSignedUrl.host.toLowerCase(),
        hostname: absoluteSignedUrl.hostname.toLowerCase(),
        source: "signed_url_absolute",
      };
    }

    const publicBaseUrl = parseUrl(
      pushImagePublicBaseUrl,
      PUSH_IMAGE_PUBLIC_BASE_URL_ENV_KEY,
    );
    const rebasedUrl = new URL(
      `${absoluteSignedUrl.pathname}${absoluteSignedUrl.search}${absoluteSignedUrl.hash}`,
      publicBaseUrl,
    );

    return {
      url: rebasedUrl.toString(),
      protocol: rebasedUrl.protocol,
      host: rebasedUrl.host.toLowerCase(),
      hostname: rebasedUrl.hostname.toLowerCase(),
      source: "public_base_url",
    };
  }

  const resolvedBaseUrl = pushImagePublicBaseUrl == null
    ? parseUrl(supabaseUrl, ENV_SECRET.SUPABASE_URL)
    : parseUrl(pushImagePublicBaseUrl, PUSH_IMAGE_PUBLIC_BASE_URL_ENV_KEY);
  const resolved = new URL(signedUrl, resolvedBaseUrl);

  return {
    url: resolved.toString(),
    protocol: resolved.protocol,
    host: resolved.host.toLowerCase(),
    hostname: resolved.hostname.toLowerCase(),
    source: pushImagePublicBaseUrl == null ? "supabase_url" : "public_base_url",
  };
}

export async function createSignedPushImageUrl(
  supabase: SupabaseClient,
  supabaseUrl: string,
  pushImagePath: string,
  pushImagePublicBaseUrl: string | null,
): Promise<ResolvedPushImageUrl> {
  const { data, error } = await supabase.storage
    .from(MEMES_PUSH_BUCKET)
    .createSignedUrl(
      pushImagePath,
      PUSH_IMAGE_SIGNED_URL_TTL_SECONDS,
    );

  if (error != null) {
    throw error;
  }

  const signedUrl = asString(data?.signedUrl);
  if (signedUrl == null) {
    throw new Error("Supabase signed URL response missing signedUrl.");
  }

  return resolvePushImageUrl(signedUrl, supabaseUrl, pushImagePublicBaseUrl);
}

export function buildFirebaseMessagePayload(
  token: string,
  notificationPayload: Record<string, string>,
  dataPayload: Record<string, string>,
  pushImageUrl: string | null,
): Record<string, unknown> {
  const messagePayload: Record<string, unknown> = {
    token,
    notification: notificationPayload,
    data: dataPayload,
  };

  if (pushImageUrl == null) {
    return messagePayload;
  }

  messagePayload.android = {
    notification: {
      image: pushImageUrl,
    },
  };
  messagePayload.apns = {
    payload: {
      aps: {
        "mutable-content": 1,
      },
    },
    fcm_options: {
      image: pushImageUrl,
    },
  };

  return messagePayload;
}

export function isInvalidFirebaseTokenError(payload: unknown): boolean {
  if (!isRecord(payload)) {
    return false;
  }

  const errorValue = payload["error"];
  if (!isRecord(errorValue)) {
    return false;
  }

  const status = asString(errorValue["status"]);
  if (status === "UNREGISTERED") {
    return true;
  }

  const details = errorValue["details"];
  if (Array.isArray(details)) {
    const hasUnregisteredDetail = details.some((detail) => {
      if (!isRecord(detail)) {
        return false;
      }
      return asString(detail["errorCode"]) === "UNREGISTERED";
    });

    if (hasUnregisteredDetail) {
      return true;
    }
  }

  const message = asString(errorValue["message"]);
  if (status === "INVALID_ARGUMENT" && message != null) {
    const normalizedMessage = message.toLowerCase();
    if (normalizedMessage.includes("registration token")) {
      return true;
    }
  }

  return false;
}

function parseFirebaseServiceAccount(rawJson: string): FirebaseServiceAccount {
  let parsed: unknown;
  try {
    parsed = JSON.parse(rawJson);
  } catch (_error) {
    throw new Error(
      `${ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON} is not valid JSON.`,
    );
  }

  if (!isRecord(parsed)) {
    throw new Error(
      `${ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON} must be a JSON object.`,
    );
  }

  const projectId = asString(parsed.project_id);
  const clientEmail = asString(parsed.client_email);
  const privateKey = asString(parsed.private_key);
  const tokenUri = asString(parsed.token_uri) ??
    "https://oauth2.googleapis.com/token";

  if (projectId == null || clientEmail == null || privateKey == null) {
    throw new Error(
      `${ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON} must include project_id, client_email, and private_key.`,
    );
  }

  return {
    project_id: projectId,
    client_email: clientEmail,
    private_key: normalizeMultilinePrivateKey(privateKey),
    token_uri: tokenUri,
  };
}

export function resolveFirebaseServiceAccount(
  getEnv: (name: string) => string | undefined,
): FirebaseServiceAccount {
  const raw = asString(getEnv(ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON));
  if (raw == null) {
    throw new Error(`${ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON} is required.`);
  }

  return parseFirebaseServiceAccount(raw);
}

function base64UrlEncodeText(value: string): string {
  const encoded = new TextEncoder().encode(value);
  return base64UrlEncodeBytes(encoded);
}

function base64UrlEncodeBytes(bytes: Uint8Array): string {
  const base64 = btoa(String.fromCharCode(...bytes));
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function pemPrivateKeyToDer(privateKeyPem: string): ArrayBuffer {
  const cleaned = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");

  const binary = atob(cleaned);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}

async function createSignedJwt(
  serviceAccount: FirebaseServiceAccount,
  now: Date,
): Promise<string> {
  const issuedAt = Math.floor(now.getTime() / 1000);
  const expiresAt = issuedAt + 3600;

  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: serviceAccount.token_uri,
    iat: issuedAt,
    exp: expiresAt,
  };

  const encodedHeader = base64UrlEncodeText(JSON.stringify(header));
  const encodedClaims = base64UrlEncodeText(JSON.stringify(claims));
  const unsignedToken = `${encodedHeader}.${encodedClaims}`;

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemPrivateKeyToDer(serviceAccount.private_key),
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(unsignedToken),
  );

  const encodedSignature = base64UrlEncodeBytes(new Uint8Array(signature));
  return `${unsignedToken}.${encodedSignature}`;
}

async function fetchFirebaseAccessToken(
  deps: HandlerDependencies,
  serviceAccount: FirebaseServiceAccount,
): Promise<string> {
  const assertion = await createSignedJwt(serviceAccount, deps.now());

  const tokenResponse = await deps.fetchFn(serviceAccount.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  let tokenPayload: unknown = null;
  try {
    tokenPayload = await tokenResponse.json();
  } catch (_error) {
    tokenPayload = null;
  }

  if (!tokenResponse.ok || !isRecord(tokenPayload)) {
    throw new Error("Failed to obtain Firebase OAuth access token.");
  }

  const accessToken = asString(tokenPayload.access_token);
  if (accessToken == null) {
    throw new Error(
      "Firebase OAuth token response did not include access_token.",
    );
  }

  return accessToken;
}

async function deactivateInvalidTokens(
  supabase: SupabaseClient,
  tokenIds: string[],
  now: Date,
): Promise<void> {
  if (tokenIds.length == 0) {
    return;
  }

  const { error } = await supabase
    .from("push_device_tokens")
    .update({
      is_active: false,
      deactivation_reason: "send_invalid",
      deactivated_at: now.toISOString(),
    })
    .in("id", tokenIds)
    .eq("is_active", true);

  if (error != null) {
    throw error;
  }
}

export function createSendNotificationPushHandler(
  overrides: Partial<HandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: HandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler(
    "send_notification_push",
    async (request: Request): Promise<Response> => {
      const methodError = requirePostMethod(request);
      if (methodError != null) {
        logEvent("warn", "send_notification_push.method_not_allowed", {
          method: request.method,
        });
        return methodError;
      }

      const authResult = requireMachineApiKey(request, deps.getEnv);
      if ("error" in authResult) {
        return authResult.error;
      }

      const parseResult = await parseJsonBody(request);
      if ("error" in parseResult) {
        logEvent("warn", "send_notification_push.invalid_json");
        return parseResult.error;
      }

      const payload = parseResult.payload;

      if (isRecord(payload)) {
        const eventType = asString(payload.type);
        const table = asString(payload.table);
        if (eventType != null && eventType !== "INSERT") {
          logEvent("info", "send_notification_push.skipped", {
            reason: "unsupported_event_type",
            received_event_type: eventType,
          });
          return jsonResponse(200, {
            success: true,
            skipped: "unsupported_event_type",
          });
        }
        if (table != null && table !== "notifications") {
          logEvent("info", "send_notification_push.skipped", {
            reason: "unsupported_table",
            received_table: table,
          });
          return jsonResponse(200, {
            success: true,
            skipped: "unsupported_table",
          });
        }
      }

      let notification: NotificationRecord;
      try {
        notification = parseNotificationRecord(payload);
      } catch (error) {
        logEvent("warn", "send_notification_push.invalid_payload", {
          error: error instanceof Error ? error.message : "unknown_error",
        });
        return errorResponse(
          400,
          "invalid_payload",
          error instanceof Error
            ? error.message
            : "Could not parse notification payload.",
        );
      }

      logEvent("info", "send_notification_push.received", {
        notification_id: notification.id,
        recipient_id: notification.recipientId,
        notification_type: notification.type,
      });

      let supabaseUrl: string;
      let supabaseSecretKey: string;
      try {
        supabaseUrl = getRequiredSecret(ENV_SECRET.SUPABASE_URL, deps.getEnv);
        supabaseSecretKey = getRequiredSecret(
          ENV_SECRET.SB_SECRET_KEY,
          deps.getEnv,
        );
      } catch (_error) {
        logEvent("error", "send_notification_push.missing_env");
        return errorResponse(
          500,
          "missing_env",
          "SUPABASE_URL and SB_SECRET_KEY are required.",
        );
      }

      let serviceAccount: FirebaseServiceAccount;
      try {
        serviceAccount = resolveFirebaseServiceAccount(deps.getEnv);
      } catch (error) {
        logEvent("error", "send_notification_push.invalid_env", {
          env_key: ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON,
          error: error instanceof Error ? error.message : "unknown_error",
        });
        return errorResponse(
          500,
          "invalid_env",
          error instanceof Error
            ? error.message
            : "Firebase service-account config is invalid.",
        );
      }

      const supabase = deps.createSupabaseAdminClient(
        supabaseUrl,
        supabaseSecretKey,
      );
      const pushImagePublicBaseUrl = asString(
        deps.getEnv(PUSH_IMAGE_PUBLIC_BASE_URL_ENV_KEY),
      );

      let pushImageUrl: string | null = null;
      if (
        notification.type === "meme_received" ||
        notification.type === "meme_laughed"
      ) {
        const pushImagePath = asString(notification.data["push_image_path"]);

        if (pushImagePath == null) {
          logEvent("warn", "send_notification_push.push_image_skipped", {
            notification_id: notification.id,
            recipient_id: notification.recipientId,
            reason: "missing_or_invalid_push_image_path",
          });
        } else {
          try {
            const resolvedPushImageUrl = await createSignedPushImageUrl(
              supabase,
              supabaseUrl,
              pushImagePath,
              pushImagePublicBaseUrl,
            );
            pushImageUrl = resolvedPushImageUrl.url;

            logEvent("info", "send_notification_push.push_image_attached", {
              notification_id: notification.id,
              recipient_id: notification.recipientId,
              push_image_path: pushImagePath,
              signed_url_ttl_seconds: PUSH_IMAGE_SIGNED_URL_TTL_SECONDS,
              image_url_host: resolvedPushImageUrl.host,
              image_url_protocol: resolvedPushImageUrl.protocol,
              image_url_source: resolvedPushImageUrl.source,
            });
          } catch (error) {
            logEvent("warn", "send_notification_push.push_image_sign_failed", {
              notification_id: notification.id,
              recipient_id: notification.recipientId,
              push_image_path: pushImagePath,
              signed_url_ttl_seconds: PUSH_IMAGE_SIGNED_URL_TTL_SECONDS,
              error: error instanceof Error ? error.message : "unknown_error",
            });
          }
        }
      }

      const { data: tokenRows, error: tokenLookupError } = await supabase
        .from("push_device_tokens")
        .select("id, fcm_token, language_code, country_code")
        .eq("user_id", notification.recipientId)
        .eq("is_active", true);

      if (tokenLookupError != null) {
        logEvent("error", "send_notification_push.token_lookup_failed", {
          notification_id: notification.id,
          recipient_id: notification.recipientId,
          error: tokenLookupError.message,
        });
        return errorResponse(
          500,
          "token_lookup_failed",
          "Failed to load recipient push tokens.",
        );
      }

      const tokens = (Array.isArray(tokenRows) ? tokenRows : [])
        .map((row) => {
          if (!isRecord(row)) {
            return null;
          }

          const id = asString(row.id);
          const fcmToken = asString(row.fcm_token);
          if (id == null || fcmToken == null) {
            return null;
          }

          return <PushDeviceTokenRow> {
            id,
            fcm_token: fcmToken,
            language_code: asString(row.language_code),
            country_code: asString(row.country_code),
          };
        })
        .filter((row): row is PushDeviceTokenRow => row != null);

      if (tokens.length === 0) {
        logEvent("info", "send_notification_push.completed", {
          notification_id: notification.id,
          recipient_id: notification.recipientId,
          skipped: "no_active_tokens",
          attempted: 0,
          delivered: 0,
          invalidated: 0,
          failed: 0,
        });
        return jsonResponse(200, {
          success: true,
          delivered: 0,
          attempted: 0,
          invalidated: 0,
          failed: 0,
        });
      }

      let accessToken: string;
      try {
        accessToken = await fetchFirebaseAccessToken(deps, serviceAccount);
      } catch (error) {
        logEvent("error", "send_notification_push.firebase_auth_failed", {
          notification_id: notification.id,
          recipient_id: notification.recipientId,
          error: error instanceof Error ? error.message : "unknown_error",
        });
        return errorResponse(
          500,
          "firebase_auth_failed",
          error instanceof Error
            ? error.message
            : "Could not authorize against Firebase.",
        );
      }

      const firebaseSendUrl =
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

      let delivered = 0;
      let failed = 0;
      const invalidTokenIds: string[] = [];
      const templateCache = new Map<string, Promise<NotificationPushTemplate>>();

      for (const tokenRow of tokens) {
        const normalizedLanguageCode = normalizeNotificationLanguage(
          tokenRow.language_code,
        );
        const normalizedCountryCode = normalizeNotificationCountry(
          tokenRow.country_code,
        );
        const cacheKey = `${normalizedLanguageCode}:${
          normalizedCountryCode ?? "null"
        }`;

        let templatePromise = templateCache.get(cacheKey);
        if (templatePromise == null) {
          templatePromise = resolveNotificationPushTemplate(
            supabase,
            notification.type,
            normalizedLanguageCode,
            normalizedCountryCode,
          );
          templateCache.set(cacheKey, templatePromise);
        }

        let template: NotificationPushTemplate;
        try {
          template = await templatePromise;
        } catch (error) {
          failed += 1;
          logEvent("warn", "send_notification_push.template_lookup_failed", {
            notification_id: notification.id,
            recipient_id: notification.recipientId,
            token_id: tokenRow.id,
            language_code: normalizedLanguageCode,
            country_code: normalizedCountryCode,
            error: error instanceof Error ? error.message : "unknown_error",
          });
          continue;
        }

        const dataPayload = buildNotificationDataPayload(notification);
        const templateVariables = buildNotificationTemplateVariables(
          notification,
          template.languageCode,
        );
        const renderedTitle = template.title == null
          ? null
          : renderTemplateText(template.title, templateVariables);
        const renderedMessage = renderTemplateText(
          template.message,
          templateVariables,
        );

        if (renderedMessage.trim().length === 0) {
          failed += 1;
          logEvent("warn", "send_notification_push.template_render_empty", {
            notification_id: notification.id,
            recipient_id: notification.recipientId,
            token_id: tokenRow.id,
            language_code: template.languageCode,
            country_code: template.countryCode,
          });
          continue;
        }

        const notificationPayload: Record<string, string> = {
          body: renderedMessage,
        };
        if (renderedTitle != null && renderedTitle.trim().length > 0) {
          notificationPayload.title = renderedTitle;
        }

        const firebaseMessagePayload = buildFirebaseMessagePayload(
          tokenRow.fcm_token,
          notificationPayload,
          dataPayload,
          pushImageUrl,
        );

        const pushResponse = await deps.fetchFn(firebaseSendUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: firebaseMessagePayload,
          }),
        });

        if (pushResponse.ok) {
          delivered += 1;
          continue;
        }

        let errorPayload: unknown = null;
        try {
          errorPayload = await pushResponse.json();
        } catch (_error) {
          errorPayload = null;
        }

        const isInvalidToken = isInvalidFirebaseTokenError(errorPayload);

        logEvent("warn", "send_notification_push.push_failed", {
          notification_id: notification.id,
          recipient_id: notification.recipientId,
          token_id: tokenRow.id,
          firebase_status: pushResponse.status,
          invalid_token: isInvalidToken,
        });

        if (isInvalidToken) {
          invalidTokenIds.push(tokenRow.id);
        } else {
          failed += 1;
        }
      }

      try {
        await deactivateInvalidTokens(supabase, invalidTokenIds, deps.now());
      } catch (error) {
        logEvent("warn", "send_notification_push.token_cleanup_failed", {
          notification_id: notification.id,
          recipient_id: notification.recipientId,
          invalidated: invalidTokenIds.length,
          error: error instanceof Error ? error.message : "unknown_error",
        });
        // Token cleanup is best-effort; send results stay successful.
      }

      logEvent("info", "send_notification_push.completed", {
        notification_id: notification.id,
        recipient_id: notification.recipientId,
        attempted: tokens.length,
        delivered,
        invalidated: invalidTokenIds.length,
        failed,
      });

      return jsonResponse(200, {
        success: true,
        attempted: tokens.length,
        delivered,
        invalidated: invalidTokenIds.length,
        failed,
      });
    },
  );
  
}

if (import.meta.main) {
  Deno.serve(createSendNotificationPushHandler());
}
