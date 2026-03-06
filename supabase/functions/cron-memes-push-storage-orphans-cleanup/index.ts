import { createStorageOrphansCleanupHandler } from "../_shared/cron/storage_orphans_cleanup.ts";
import type { StorageOrphansCleanupHandlerDependencies } from "../_shared/cron/storage_orphans_cleanup.ts";

export function createCronMemesPushStorageOrphansCleanupHandler(
  overrides: Partial<StorageOrphansCleanupHandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  return createStorageOrphansCleanupHandler(
    {
      functionName: "cron_memes_push_storage_orphans_cleanup",
      bucket: "memes_push",
      referenceColumn: "push_image_path",
      cleanupFailedMessage:
        "Failed to clean up orphaned memes_push storage files.",
    },
    overrides,
  );
}

if (import.meta.main) {
  Deno.serve(createCronMemesPushStorageOrphansCleanupHandler());
}
