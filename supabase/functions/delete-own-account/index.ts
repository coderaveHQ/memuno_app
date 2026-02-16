import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// CORS headers returned for preflight and JSON responses.
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Standardized JSON error shape returned by this function.
type ErrorPayload = {
  code: string;
  message: string;
};

// Helper for consistent JSON responses across all code paths.
const response = (status: number, body: object) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (request) => {
  // CORS preflight is answered early without auth checks.
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // This endpoint is intentionally POST-only to avoid accidental invocation.
  if (request.method !== "POST") {
    return response(
      405,
      <ErrorPayload> {
        code: "method_not_allowed",
        message: "Only POST requests are supported.",
      },
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = request.headers.get("Authorization");

  // All required environment variables must be present in function config.
  if (
    supabaseUrl == null ||
    supabaseAnonKey == null ||
    supabaseServiceRoleKey == null
  ) {
    return response(
      500,
      <ErrorPayload> {
        code: "missing_env",
        message: "Function environment is not configured correctly.",
      },
    );
  }

  // Caller must provide a bearer token we can validate.
  if (authorization == null || authorization.length === 0) {
    return response(
      401,
      <ErrorPayload> {
        code: "unauthorized",
        message: "Missing authorization header.",
      },
    );
  }

  // Normalize "Bearer <token>" input and reject empty tokens.
  const token = authorization.replace(/^Bearer\s+/i, "").trim();
  if (token.length === 0) {
    return response(
      401,
      <ErrorPayload> {
        code: "unauthorized",
        message: "Missing bearer token.",
      },
    );
  }

  // User-scoped client validates the supplied token against Supabase Auth.
  const authedClient = createClient(supabaseUrl, supabaseAnonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: { headers: { Authorization: authorization } },
  });

  // Service-role client performs privileged delete operations.
  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Resolve the authenticated user from the bearer token.
  const { data: userData, error: userError } = await authedClient.auth.getUser(
    token,
  );

  if (userError != null) {
    return response(
      401,
      <ErrorPayload> {
        code: "unauthorized",
        message: "Could not resolve authenticated user.",
      },
    );
  }

  // No user means the token did not map to an active authenticated identity.
  const userId = userData.user?.id ?? null;
  if (userId == null) {
    return response(
      401,
      <ErrorPayload> {
        code: "unauthorized",
        message: "No authenticated user found.",
      },
    );
  }

  // Permanently delete the auth user; profile rows cascade via FK/trigger rules.
  const { error: deleteError } = await adminClient.auth.admin.deleteUser(
    userId,
  );
  if (deleteError != null) {
    return response(
      500,
      <ErrorPayload> {
        code: "delete_failed",
        message: "Could not delete account.",
      },
    );
  }

  // Client treats this as a successful account deletion.
  return response(200, { success: true });
});
