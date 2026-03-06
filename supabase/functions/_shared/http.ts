import type { ErrorPayload } from "./types/errors.ts";
import {
  logEvent,
  logLifecycleFailure,
  logLifecycleStart,
  logLifecycleSuccess,
} from "./logger.ts";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

export type EdgeHandler = (request: Request) => Promise<Response>;

export function jsonResponse(status: number, body: object): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function errorResponse(
  status: number,
  code: string,
  message: string,
): Response {
  const payload: ErrorPayload = { code, message };
  return jsonResponse(status, payload);
}

export function handleCorsPreflight(request: Request): Response | null {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  return null;
}

export function requirePostMethod(request: Request): Response | null {
  if (request.method === "POST") {
    return null;
  }

  return errorResponse(
    405,
    "method_not_allowed",
    "Only POST requests are supported.",
  );
}

export async function parseJsonBody(
  request: Request,
): Promise<{ payload: unknown } | { error: Response }> {
  try {
    const payload = await request.json();
    return { payload };
  } catch (_error) {
    return {
      error: errorResponse(400, "invalid_json", "Request body must be valid JSON."),
    };
  }
}

export function createEdgeHandler(
  functionName: string,
  handler: EdgeHandler,
): EdgeHandler {
  return async (request: Request): Promise<Response> => {
    const preflightResponse = handleCorsPreflight(request);
    if (preflightResponse != null) {
      return preflightResponse;
    }

    logLifecycleStart(functionName, { method: request.method });

    try {
      const response = await handler(request);
      if (response.status >= 200 && response.status < 400) {
        logLifecycleSuccess(functionName, {
          method: request.method,
          status: response.status,
        });
      } else {
        logLifecycleFailure(
          functionName,
          new Error(`HTTP ${response.status}`),
          {
            method: request.method,
            status: response.status,
          },
        );
        logEvent("warn", `${functionName}.completed_with_error_status`, {
          method: request.method,
          status: response.status,
        });
      }
      return response;
    } catch (error) {
      logLifecycleFailure(functionName, error, { method: request.method });
      return errorResponse(500, "internal_error", "Unexpected internal error.");
    }
  };
}
