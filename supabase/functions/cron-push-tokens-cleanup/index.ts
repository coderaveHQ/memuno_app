import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { requireMachineApiKey } from "../_shared/auth.ts";
import { getEnvByName, type EnvReader } from "../_shared/env.ts";
import { createEdgeHandler, errorResponse, jsonResponse, requirePostMethod } from "../_shared/http.ts";
import { logEvent, toError } from "../_shared/logger.ts";
import {
  createSupabaseAdminClient,
  resolveSupabaseAdminSecrets,
} from "../_shared/supabase.ts";

type HandlerDependencies = {
  createSupabaseAdminClient: (
    supabaseUrl: string,
    secretKey: string,
  ) => SupabaseClient;
  getEnv: EnvReader;
};

const defaultDependencies: HandlerDependencies = {
  createSupabaseAdminClient,
  getEnv: getEnvByName,
};

const DEFAULT_OLDER_THAN = "90 days";

export function createCronPushTokensCleanupHandler(
  overrides: Partial<HandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: HandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler("cron_push_tokens_cleanup", async (request) => {
    const methodError = requirePostMethod(request);
    if (methodError != null) {
      return methodError;
    }

    const authResult = requireMachineApiKey(request, deps.getEnv);
    if ("error" in authResult) {
      return authResult.error;
    }

    let secrets: { supabaseUrl: string; secretKey: string };
    try {
      secrets = resolveSupabaseAdminSecrets(deps.getEnv);
    } catch (_error) {
      return errorResponse(
        500,
        "missing_env",
        "SUPABASE_URL and SB_SECRET_KEY are required.",
      );
    }

    const olderThan = DEFAULT_OLDER_THAN;
    const supabase = deps.createSupabaseAdminClient(
      secrets.supabaseUrl,
      secrets.secretKey,
    );

    try {
      const { data, error } = await supabase.rpc(
        "push_tokens_cleanup_inactive",
        { p_older_than: olderThan },
      );

      if (error != null) {
        throw error;
      }

      const deletedCount = typeof data === "number" ? data : 0;
      logEvent("info", "cron_push_tokens_cleanup.cleanup_completed", {
        older_than: olderThan,
        deleted_count: deletedCount,
      });

      return jsonResponse(200, {
        success: true,
        older_than: olderThan,
        deleted_count: deletedCount,
      });
    } catch (error) {
      const resolved = toError(error);
      logEvent("error", "cron_push_tokens_cleanup.cleanup_failed", {
        older_than: olderThan,
        error: resolved.message,
      });
      return errorResponse(
        500,
        "cleanup_failed",
        "Failed to clean up inactive push tokens.",
      );
    }
  });
}

if (import.meta.main) {
  Deno.serve(createCronPushTokensCleanupHandler());
}
