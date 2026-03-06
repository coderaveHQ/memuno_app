import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import {
  ENV_SECRET,
  type EnvReader,
  getEnvByName,
  getRequiredSecret,
} from "./env.ts";

type SupabaseAuthOptions = {
  auth: {
    autoRefreshToken: boolean;
    persistSession: boolean;
  };
};

const defaultAuthOptions: SupabaseAuthOptions = {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
};

export type SupabaseAdminSecrets = {
  supabaseUrl: string;
  secretKey: string;
};

export type SupabasePublishableSecrets = {
  supabaseUrl: string;
  publishableKey: string;
};

export function resolveSupabaseAdminSecrets(
  getEnv: EnvReader = getEnvByName,
): SupabaseAdminSecrets {
  return {
    supabaseUrl: getRequiredSecret(ENV_SECRET.SUPABASE_URL, getEnv),
    secretKey: getRequiredSecret(
      ENV_SECRET.SB_SECRET_KEY,
      getEnv,
    ),
  };
}

export function resolveSupabasePublishableSecrets(
  getEnv: EnvReader = getEnvByName,
): SupabasePublishableSecrets {
  return {
    supabaseUrl: getRequiredSecret(ENV_SECRET.SUPABASE_URL, getEnv),
    publishableKey: getRequiredSecret(ENV_SECRET.SB_PUBLISHABLE_KEY, getEnv),
  };
}

export function createSupabaseAdminClient(
  supabaseUrl: string,
  secretKey: string,
): SupabaseClient {
  return createClient(supabaseUrl, secretKey, defaultAuthOptions);
}

export function createSupabasePublishableClient(
  supabaseUrl: string,
  publishableKey: string,
  authorizationHeader?: string,
): SupabaseClient {
  if (authorizationHeader == null) {
    return createClient(supabaseUrl, publishableKey, defaultAuthOptions);
  }

  return createClient(supabaseUrl, publishableKey, {
    ...defaultAuthOptions,
    global: {
      headers: {
        Authorization: authorizationHeader,
      },
    },
  });
}
