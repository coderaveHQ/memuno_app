import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { requireMachineApiKey } from "../auth.ts";
import { getEnvByName, type EnvReader } from "../env.ts";
import {
  createEdgeHandler,
  errorResponse,
  jsonResponse,
  requirePostMethod,
} from "../http.ts";
import { logEvent, toError } from "../logger.ts";
import {
  createSupabaseAdminClient,
  resolveSupabaseAdminSecrets,
} from "../supabase.ts";

export type StorageOrphansCleanupConfig = {
  functionName: string;
  bucket: string;
  referenceColumn: string;
  cleanupFailedMessage: string;
};

export type StorageOrphansCleanupHandlerDependencies = {
  createSupabaseAdminClient: (
    supabaseUrl: string,
    secretKey: string,
  ) => SupabaseClient;
  now: () => Date;
  getEnv: EnvReader;
};

type StorageObjectRow = {
  name: string;
};

type CleanupResult = {
  candidateCount: number;
  orphanCount: number;
  deletedCount: number;
};

const DEFAULT_BATCH_LIMIT = 500;
const DEFAULT_MIN_AGE_MINUTES = 60;

const defaultDependencies: StorageOrphansCleanupHandlerDependencies = {
  createSupabaseAdminClient,
  now: () => new Date(),
  getEnv: getEnvByName,
};

function asString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

async function loadCandidatePaths(
  supabase: SupabaseClient,
  bucket: string,
  cutoffIso: string,
  batchLimit: number,
): Promise<string[]> {
  const { data, error } = await supabase
    .schema("storage")
    .from("objects")
    .select("name")
    .eq("bucket_id", bucket)
    .lt("created_at", cutoffIso)
    .order("created_at", { ascending: true })
    .limit(batchLimit);

  if (error != null) {
    throw error;
  }

  if (!Array.isArray(data)) {
    return [];
  }

  return data
    .map((row) => asString((row as StorageObjectRow).name))
    .filter((value): value is string => value != null);
}

async function loadReferencedPaths(
  supabase: SupabaseClient,
  referenceColumn: string,
  candidates: string[],
): Promise<Set<string>> {
  if (candidates.length === 0) {
    return new Set<string>();
  }

  const { data, error } = await supabase
    .from("memes")
    .select(referenceColumn)
    .in(referenceColumn, candidates);

  if (error != null) {
    throw error;
  }

  const referenced = new Set<string>();
  for (const row of data ?? []) {
    if (!isRecord(row)) {
      continue;
    }

    const value = asString(row[referenceColumn]);
    if (value != null) {
      referenced.add(value);
    }
  }

  return referenced;
}

async function cleanupBucketOrphans(
  supabase: SupabaseClient,
  bucket: string,
  referenceColumn: string,
  cutoffIso: string,
  batchLimit: number,
): Promise<CleanupResult> {
  const candidates = await loadCandidatePaths(supabase, bucket, cutoffIso, batchLimit);
  const referenced = await loadReferencedPaths(supabase, referenceColumn, candidates);
  const orphans = candidates.filter((path) => !referenced.has(path));

  if (orphans.length === 0) {
    return {
      candidateCount: candidates.length,
      orphanCount: 0,
      deletedCount: 0,
    };
  }

  const { data, error } = await supabase.storage.from(bucket).remove(orphans);
  if (error != null) {
    throw error;
  }

  return {
    candidateCount: candidates.length,
    orphanCount: orphans.length,
    deletedCount: Array.isArray(data) ? data.length : orphans.length,
  };
}

export function createStorageOrphansCleanupHandler(
  config: StorageOrphansCleanupConfig,
  overrides: Partial<StorageOrphansCleanupHandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  const deps: StorageOrphansCleanupHandlerDependencies = {
    ...defaultDependencies,
    ...overrides,
  };

  return createEdgeHandler(config.functionName, async (request: Request) => {
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

    const batchLimit = DEFAULT_BATCH_LIMIT;
    const minAgeMinutes = DEFAULT_MIN_AGE_MINUTES;
    const cutoffIso = new Date(
      deps.now().getTime() - minAgeMinutes * 60 * 1000,
    ).toISOString();

    const supabase = deps.createSupabaseAdminClient(
      secrets.supabaseUrl,
      secrets.secretKey,
    );

    try {
      const result = await cleanupBucketOrphans(
        supabase,
        config.bucket,
        config.referenceColumn,
        cutoffIso,
        batchLimit,
      );

      logEvent("info", `${config.functionName}.cleanup_completed`, {
        bucket: config.bucket,
        batch_limit: batchLimit,
        min_age_minutes: minAgeMinutes,
        candidate_count: result.candidateCount,
        orphan_count: result.orphanCount,
        deleted_count: result.deletedCount,
      });

      return jsonResponse(200, {
        success: true,
        bucket: config.bucket,
        batch_limit: batchLimit,
        min_age_minutes: minAgeMinutes,
        candidate_count: result.candidateCount,
        orphan_count: result.orphanCount,
        deleted_count: result.deletedCount,
      });
    } catch (error) {
      const resolved = toError(error);
      logEvent("error", `${config.functionName}.cleanup_failed`, {
        bucket: config.bucket,
        batch_limit: batchLimit,
        min_age_minutes: minAgeMinutes,
        error: resolved.message,
      });

      return errorResponse(500, "cleanup_failed", config.cleanupFailedMessage);
    }
  });
}
