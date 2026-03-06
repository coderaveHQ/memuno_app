import { createStorageOrphansCleanupHandler } from "../_shared/cron/storage_orphans_cleanup.ts";
import type { StorageOrphansCleanupHandlerDependencies } from "../_shared/cron/storage_orphans_cleanup.ts";

export function createCronMemesStorageOrphansCleanupHandler(
  overrides: Partial<StorageOrphansCleanupHandlerDependencies> = {},
): (request: Request) => Promise<Response> {
  return createStorageOrphansCleanupHandler(
    {
      functionName: "cron_memes_storage_orphans_cleanup",
      bucket: "memes",
      referenceColumn: "image_path",
      cleanupFailedMessage: "Failed to clean up orphaned memes storage files.",
    },
    overrides,
  );
}

if (import.meta.main) {
  Deno.serve(createCronMemesStorageOrphansCleanupHandler());
}
