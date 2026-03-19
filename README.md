# Memuno App

Make memes fast: pick a template, add your caption, and send it to friends instantly.

## Developer Notes

### Prerequisites

- [Flutter](https://docs.flutter.dev/install) installed
- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=macos) installed
- [NodeJS](https://nodejs.org/en/download) installed

### Declarative Database Schema (public)

This project uses an incremental declarative schema workflow for the `public` schema:

- Declarative source of truth: `supabase/schemas/*.sql`
- Existing `supabase/migrations/*.sql` remain unchanged (no history rewrite / squash)
- New schema changes should be generated as versioned migrations

Current schema file order is configured in `supabase/config.toml`:

- `./schemas/00_extensions.sql`
- `./schemas/10_types.sql`
- `./schemas/20_tables.sql`
- `./schemas/30_indexes.sql`
- `./schemas/40_functions.sql`
- `./schemas/50_triggers.sql`
- `./schemas/60_rls_policies.sql`

#### Standard workflow for schema changes

1. Edit the relevant file(s) in `supabase/schemas/`.
2. Generate a migration from the declarative diff:

```sh
supabase db diff --local --schema public -f <migration_name>
```

3. Review the generated file in `supabase/migrations/`.

#### Caveats kept as manual/versioned SQL migrations

Do not rely on declarative `schema_paths` for these:

- DML and backfills (`INSERT`, `UPDATE`, `DELETE`)
- `cron.schedule(...)`
- `alter publication ...`
- `storage.buckets` rows
- `grant` / `revoke` and `comment on`

### Local Development (development)

##### 1. Copy env files and fill values

- `.env.development.example` -> `.env.development`
- `.env.staging.example` -> `.env.staging`
- `.env.production.example` -> `.env.production`
- `supabase/.env.local.example` -> `supabase/.env.local`

##### 2. Start local Supabase

```sh
supabase start
```

##### 3. Ensure local Vault secrets are set

The migration creates helper `public.upsert_vault_secret(...)` and manages triggers + cron schedules.
Set environment-specific values after migrations are applied:
Run these statements as the project owner role (SQL Editor / migration role).

```sql
select public.upsert_vault_secret(
  'edge_functions_base_url',
  'http://host.docker.internal:54321',
  'Local base URL for internal DB->Edge calls'
);

select public.upsert_vault_secret(
  'edge_functions_apikey',
  '<LOCAL_SB_SECRET_KEY>',
  'Local machine apikey used by webhook/cron invocations'
);
```

##### 4. Serve Edge Functions

```sh
supabase functions serve --env-file supabase/.env.local
```

##### 5. Install and run app

```sh
flutter pub get
```

```sh
dart run build_runner build --delete-conflicting-outputs
```

```sh
flutter gen-l10n
```

```sh
flutter run --flavor development --dart-define-from-file=.env.development
```

### Hosted Setup (staging + production)

##### 1. Set Edge Function runtime secrets

Set secrets per project (staging and production each separately):

- **SB_PUBLISHABLE_KEY**: <SB_PUBLISHABLE_KEY>
- **SB_SECRET_KEY**: <SB_SECRET_KEY>
- **FIREBASE_SERVICE_ACCOUNT_JSON**: <ONE_LINE_JSON>

##### 2. Set hosted Vault secrets

Run as project owner role (SQL Editor / migration role):

```sql
select public.upsert_vault_secret(
  'edge_functions_base_url',
  'https://<PROJECT_REF>.supabase.co',
  'Hosted base URL for internal DB->Edge calls'
);

select public.upsert_vault_secret(
  'edge_functions_apikey',
  '<SB_SECRET_KEY>',
  'Hosted machine apikey used by webhook/cron invocations'
);
```

### Tools

#### Meme Template Uploader

This tool helps uploading meme templates to storage and linking them to the database.

##### 1. Navigate into the folder

```sh
cd tools/memuno-template-uploader/
```

##### 2. Install packages

```sh
npm i
```

##### 3. Run the App

```sh
npm run dev
```
