# Memuno App

Make memes fast: pick a template, add your caption, and send it to friends instantly.

## Developer Notes

### Prerequisites

- [Flutter](https://docs.flutter.dev/install) installed
- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=macos) installed
- [NodeJS](https://nodejs.org/en/download) installed

### Releases

To build a new .ipa file for iOS switch to the `production` branch and run the following command.

```sh
flutter build ipa --flavor production --dart-define-from-file=.env.production --release --export-method app-store --build-name="$(grep -E '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)" --build-number="$(date -u +%s)"
```

### Working with git

1. Start work (feature branch from `development`)

```sh
git fetch origin --prune
git switch development
git pull --ff-only origin development
git switch -c feature/<ticket>-<name>
```

2. Open PR: `feature/...` -> `development`

- Merge method: **Create a merge commit**

3. After feature PR merge cleanup

```sh
git switch development
git pull --ff-only origin development
git branch -d feature/<ticket>-<name>
git push origin --delete feature/<ticket>-<name>   # if not auto-deleted
```

4. Promote to `staging` with PR

- Open PR: `development` -> `staging`
- Merge method: **Create a merge commit**
- Do not squash and do not rebase this PR

5. After `staging` promotion PR merge cleanup

- No sync-back action needed
- Update local branches:

```sh
git fetch origin --prune
git switch development && git pull --ff-only origin development
git switch staging && git pull --ff-only origin staging
```

6. Promote to `production` with PR

- Open PR: `staging` -> `production`
- Merge method: **Create a merge commit**
- Do not squash and do not rebase this PR

7. After `production` promotion PR merge cleanup

- Update local branches:

```sh
git fetch origin --prune
git switch development && git pull --ff-only origin development
git switch staging && git pull --ff-only origin staging
git switch production && git pull --ff-only origin production
```

8. Start next feature branch from updated `development`.

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

- `meme_templates/.env.development.example` -> `meme_templates/.env.development`
- `meme_templates/.env.staging.example` -> `meme_templates/.env.staging`
- `meme_templates/.env.production.example` -> `meme_templates/.env.production`

##### 2. Update Supabase configuration

Navigate into `supabase/config.toml` and update your local LAN IP in:

- `auth.additional_redirect_urls`

##### 3. Start local Supabase

```sh
supabase start
```

##### 4. Ensure local Vault secrets are set

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

##### 5. Serve Edge Functions

```sh
supabase functions serve --env-file supabase/.env.local
```

##### 6. Serve legal pages locally (optional for development)

Ensure `.env.development` contains:

- `LEGAL_BASE_URL=http://<YOUR-LAN-IP>:8080/development/legal`

Build the legal site:

```sh
legal/scripts/build_legal_site.sh
```

Serve the generated static files on all interfaces:

```sh
cd legal/dist
python3 -m http.server 8080 --bind 0.0.0.0
```

Use the same LAN IP in `LEGAL_BASE_URL` so emulators and real devices can reach the host machine.

##### 7. Install and run app

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
- **LEGAL_CALLBACK_BASE_URL**: <URL>

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
