import { errorResponse } from "./http.ts";
import { ENV_SECRET, getEnvByName, getRequiredSecret, type EnvReader } from "./env.ts";

export type BearerAuth = {
  authorizationHeader: string;
  token: string;
};

export type MachineApiKeyAuth = {
  apiKey: string;
};

const textEncoder = new TextEncoder();

export function extractBearerToken(authorizationHeader: string): string | null {
  const token = authorizationHeader.replace(/^Bearer\s+/i, "").trim();
  return token.length > 0 ? token : null;
}

function constantTimeEquals(left: string, right: string): boolean {
  const leftBytes = textEncoder.encode(left);
  const rightBytes = textEncoder.encode(right);
  const maxLength = Math.max(leftBytes.length, rightBytes.length);

  let diff = leftBytes.length ^ rightBytes.length;
  for (let i = 0; i < maxLength; i += 1) {
    const leftValue = i < leftBytes.length ? leftBytes[i] : 0;
    const rightValue = i < rightBytes.length ? rightBytes[i] : 0;
    diff |= leftValue ^ rightValue;
  }

  return diff === 0;
}

export function requireBearerAuth(
  request: Request,
): { value: BearerAuth } | { error: Response } {
  const authorizationHeader = request.headers.get("Authorization");
  if (authorizationHeader == null || authorizationHeader.trim().length === 0) {
    return {
      error: errorResponse(401, "unauthorized", "Missing authorization header."),
    };
  }

  const token = extractBearerToken(authorizationHeader);
  if (token == null) {
    return {
      error: errorResponse(401, "unauthorized", "Missing bearer token."),
    };
  }

  return {
    value: {
      authorizationHeader,
      token,
    },
  };
}

export function requireMachineApiKey(
  request: Request,
  getEnv: EnvReader = getEnvByName,
): { value: MachineApiKeyAuth } | { error: Response } {
  const providedApiKey = request.headers.get("apikey")?.trim() ?? "";
  if (providedApiKey.length === 0) {
    return {
      error: errorResponse(401, "unauthorized", "Missing apikey header."),
    };
  }

  let expectedApiKey: string;
  try {
    expectedApiKey = getRequiredSecret(ENV_SECRET.SB_SECRET_KEY, getEnv);
  } catch (_error) {
    return {
      error: errorResponse(500, "missing_env", "SB_SECRET_KEY is required."),
    };
  }

  if (!constantTimeEquals(providedApiKey, expectedApiKey)) {
    return {
      error: errorResponse(401, "unauthorized", "Invalid apikey."),
    };
  }

  return {
    value: {
      apiKey: providedApiKey,
    },
  };
}
