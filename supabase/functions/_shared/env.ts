export const ENV_SECRET = {
  SUPABASE_URL: "SUPABASE_URL",
  SB_PUBLISHABLE_KEY: "SB_PUBLISHABLE_KEY",
  SB_SECRET_KEY: "SB_SECRET_KEY",
  FIREBASE_SERVICE_ACCOUNT_JSON: "FIREBASE_SERVICE_ACCOUNT_JSON",
  PUSH_IMAGE_PUBLIC_BASE_URL: "PUSH_IMAGE_PUBLIC_BASE_URL",
} as const;

export type EnvSecretKey = typeof ENV_SECRET[keyof typeof ENV_SECRET];
export type EnvReader = (name: string) => string | undefined;

export type EdgeSecrets = {
  supabase: {
    url: string | null;
    publishableKey: string | null;
    secretKey: string | null;
  };
  firebase: {
    serviceAccountJson: string | null;
  };
  pushImage: {
    publicBaseUrl: string | null;
  };
};

export function getEnvByName(name: string): string | undefined {
  return Deno.env.get(name);
}

export function asNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

export function getOptionalSecret(
  key: EnvSecretKey,
  getEnv: EnvReader = getEnvByName,
): string | null {
  return asNonEmptyString(getEnv(key));
}

export function getRequiredSecret(
  key: EnvSecretKey,
  getEnv: EnvReader = getEnvByName,
): string {
  const value = getOptionalSecret(key, getEnv);
  if (value == null) {
    throw new Error(`Missing required environment variable: ${key}`);
  }

  return value;
}

export function getEdgeSecrets(
  getEnv: EnvReader = getEnvByName,
): EdgeSecrets {
  return {
    supabase: {
      url: getOptionalSecret(ENV_SECRET.SUPABASE_URL, getEnv),
      publishableKey: getOptionalSecret(
        ENV_SECRET.SB_PUBLISHABLE_KEY,
        getEnv,
      ),
      secretKey: getOptionalSecret(ENV_SECRET.SB_SECRET_KEY, getEnv),
    },
    firebase: {
      serviceAccountJson: getOptionalSecret(
        ENV_SECRET.FIREBASE_SERVICE_ACCOUNT_JSON,
        getEnv,
      ),
    },
    pushImage: {
      publicBaseUrl: getOptionalSecret(
        ENV_SECRET.PUSH_IMAGE_PUBLIC_BASE_URL,
        getEnv,
      ),
    },
  };
}
