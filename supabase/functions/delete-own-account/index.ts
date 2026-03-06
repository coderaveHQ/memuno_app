import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { requireBearerAuth } from "../_shared/auth.ts";
import { getEnvByName, type EnvReader } from "../_shared/env.ts";
import {
  createEdgeHandler,
  errorResponse,
  jsonResponse,
  requirePostMethod,
} from "../_shared/http.ts";
import { logEvent } from "../_shared/logger.ts";
import {
  createSupabaseAdminClient,
  createSupabasePublishableClient,
  resolveSupabaseAdminSecrets,
  resolveSupabasePublishableSecrets,
} from "../_shared/supabase.ts";

type HandlerDependencies = {
  getEnv: EnvReader;
  createSupabaseAdminClient: (
    supabaseUrl: string,
    secretKey: string,
  ) => SupabaseClient;
  createSupabasePublishableClient: (
    supabaseUrl: string,
    publishableKey: string,
    authorizationHeader?: string,
  ) => SupabaseClient;
};

const defaultDependencies: HandlerDependencies = {
  getEnv: getEnvByName,
  createSupabaseAdminClient,
  createSupabasePublishableClient,
};

export function createDeleteOwnAccountHandler(
  overrides: Partial<HandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: HandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler("delete_own_account", async (request: Request) => {
    const methodError = requirePostMethod(request);
    if (methodError != null) {
      return methodError;
    }

    const authResult = requireBearerAuth(request);
    if ("error" in authResult) {
      return authResult.error;
    }

    let adminSecrets: { supabaseUrl: string; secretKey: string };
    let publishableSecrets: { supabaseUrl: string; publishableKey: string };
    try {
      adminSecrets = resolveSupabaseAdminSecrets(deps.getEnv);
      publishableSecrets = resolveSupabasePublishableSecrets(deps.getEnv);
    } catch (_error) {
      return errorResponse(
        500,
        "missing_env",
        "SUPABASE_URL, SB_PUBLISHABLE_KEY, and SB_SECRET_KEY are required.",
      );
    }

    const authedClient = deps.createSupabasePublishableClient(
      publishableSecrets.supabaseUrl,
      publishableSecrets.publishableKey,
      authResult.value.authorizationHeader,
    );

    const adminClient = deps.createSupabaseAdminClient(
      adminSecrets.supabaseUrl,
      adminSecrets.secretKey,
    );

    const { data: userData, error: userError } = await authedClient.auth.getUser(
      authResult.value.token,
    );

    if (userError != null) {
      return errorResponse(
        401,
        "unauthorized",
        "Could not resolve authenticated user.",
      );
    }

    const userId = userData.user?.id ?? null;
    if (userId == null) {
      return errorResponse(401, "unauthorized", "No authenticated user found.");
    }

    const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteError != null) {
      logEvent("error", "delete_own_account.delete_failed", {
        user_id: userId,
        error: deleteError.message,
      });
      return errorResponse(500, "delete_failed", "Could not delete account.");
    }

    logEvent("success", "delete_own_account.deleted", {
      user_id: userId,
    });

    return jsonResponse(200, { success: true });
  });
}

if (import.meta.main) {
  Deno.serve(createDeleteOwnAccountHandler());
}
