import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  asNonEmptyString,
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
import {
  createSupabasePublishableClient,
  resolveSupabasePublishableSecrets,
} from "../_shared/supabase.ts";

type CanonicalLocale = "en-US" | "de-DE";

type RequestPayload = {
  email: string;
  locale: CanonicalLocale;
};

type HandlerDependencies = {
  getEnv: EnvReader;
  createSupabasePublishableClient: (
    supabaseUrl: string,
    publishableKey: string,
    authorizationHeader?: string,
  ) => SupabaseClient;
};

const defaultDependencies: HandlerDependencies = {
  getEnv: getEnvByName,
  createSupabasePublishableClient,
};

const GENERIC_SUCCESS_PAYLOAD = { success: true };
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const DEFAULT_LOCALE: CanonicalLocale = "en-US";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseLocale(value: unknown): CanonicalLocale {
  const locale = asNonEmptyString(value)?.toLowerCase();
  if (locale == null) {
    return DEFAULT_LOCALE;
  }

  if (locale === "de" || locale === "de-de") {
    return "de-DE";
  }
  if (locale === "en" || locale === "en-us") {
    return "en-US";
  }
  return DEFAULT_LOCALE;
}

function parseEmail(value: unknown): string | null {
  const email = asNonEmptyString(value)?.toLowerCase();
  if (email == null) {
    return null;
  }

  if (email.length > 254 || !EMAIL_PATTERN.test(email)) {
    return null;
  }

  return email;
}

function parseRequestPayload(payload: unknown): RequestPayload | Response {
  if (!isRecord(payload)) {
    return errorResponse(400, "invalid_payload", "Request payload must be an object.");
  }

  const email = parseEmail(payload.email);
  if (email == null) {
    return errorResponse(400, "invalid_payload", "A valid email is required.");
  }

  return {
    email,
    locale: parseLocale(payload.locale),
  };
}

function normalizeBaseUrl(rawUrl: string, envKey: string): string {
  let parsed: URL;
  try {
    parsed = new URL(rawUrl);
  } catch (_error) {
    throw new Error(`${envKey} must be a valid absolute URL.`);
  }

  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
    throw new Error(`${envKey} must use http or https.`);
  }

  const pathname = parsed.pathname.replace(/\/+$/, "");
  parsed.pathname = pathname.length > 0 ? pathname : "/";
  parsed.search = "";
  parsed.hash = "";

  return parsed.toString().replace(/\/$/, "");
}

function resolveLegalCallbackBaseUrl(getEnv: EnvReader): string {
  return normalizeBaseUrl(
    getRequiredSecret(ENV_SECRET.LEGAL_CALLBACK_BASE_URL, getEnv),
    ENV_SECRET.LEGAL_CALLBACK_BASE_URL,
  );
}

function buildConfirmRedirectUrl(baseUrl: string, locale: CanonicalLocale): string {
  return `${baseUrl}/${locale}/account-deletion-confirm/`;
}

export function createRequestAccountDeletionLinkHandler(
  overrides: Partial<HandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: HandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler(
    "request_account_deletion_link",
    async (request: Request) => {
      const methodError = requirePostMethod(request);
      if (methodError != null) {
        return methodError;
      }

      const bodyResult = await parseJsonBody(request);
      if ("error" in bodyResult) {
        return bodyResult.error;
      }

      const parsedPayload = parseRequestPayload(bodyResult.payload);
      if (parsedPayload instanceof Response) {
        return parsedPayload;
      }

      let publishableSecrets: { supabaseUrl: string; publishableKey: string };
      let callbackBaseUrl: string;
      try {
        publishableSecrets = resolveSupabasePublishableSecrets(deps.getEnv);
        callbackBaseUrl = resolveLegalCallbackBaseUrl(deps.getEnv);
      } catch (error) {
        logEvent("error", "request_account_deletion_link.missing_env", {
          error: error instanceof Error ? error.message : String(error),
        });
        return errorResponse(
          500,
          "missing_env",
          "SUPABASE_URL, SB_PUBLISHABLE_KEY, and LEGAL_CALLBACK_BASE_URL are required.",
        );
      }

      const client = deps.createSupabasePublishableClient(
        publishableSecrets.supabaseUrl,
        publishableSecrets.publishableKey,
      );

      const emailRedirectTo = buildConfirmRedirectUrl(
        callbackBaseUrl,
        parsedPayload.locale,
      );

      const { error } = await client.auth.signInWithOtp({
        email: parsedPayload.email,
        options: {
          shouldCreateUser: false,
          emailRedirectTo,
        },
      });

      if (error != null) {
        logEvent("warn", "request_account_deletion_link.otp_dispatch_failed", {
          locale: parsedPayload.locale,
          callback_base_url: callbackBaseUrl,
          error: error.message,
          error_code: error.code ?? null,
          error_status: error.status ?? null,
        });
        return jsonResponse(200, GENERIC_SUCCESS_PAYLOAD);
      }

      logEvent("success", "request_account_deletion_link.otp_dispatched", {
        locale: parsedPayload.locale,
        callback_base_url: callbackBaseUrl,
      });

      return jsonResponse(200, GENERIC_SUCCESS_PAYLOAD);
    },
  );
}

if (import.meta.main) {
  Deno.serve(createRequestAccountDeletionLinkHandler());
}
