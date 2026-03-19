-- Required extensions for objects in the declarative public schema.
-- Caveat-scope objects (cron jobs, bucket rows, publication changes) stay in versioned migrations.
create extension if not exists pgcrypto with schema extensions;
create extension if not exists pg_net with schema extensions;
create extension if not exists pg_trgm with schema extensions;
create extension if not exists supabase_vault with schema vault;
create extension if not exists unaccent with schema extensions;
create extension if not exists pg_cron with schema extensions;
