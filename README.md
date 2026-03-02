# Memuno App

Make memes fast: pick a template, add your caption, and send it to friends instantly.

## Developer Notes

### Prerequisites

- [Flutter](https://docs.flutter.dev/install) installed
- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started?queryGroups=platform&platform=macos) installed
- [NodeJS](https://nodejs.org/en/download) installed

### Running the App

##### 1. Copy the `.env` files remove the `.example` postfix and fill them respectively

- `.env.local.example`
- `supabase/.env.local.example`

##### 2. Start the Supabase backend

```sh
supabase start
```

##### 3. Push Notifications Setup

Push delivery is triggered by a database webhook on `public.notifications` (`INSERT`) that calls the `send-notification-push` Edge Function.

The webhook must send:
- `Authorization: Bearer <service_role_key>`

1. Get your local service-role key from `supabase status -o env | grep SERVICE_ROLE_KEY`.
2. Provision the webhook trigger **once** (or after `supabase db reset`):

```sql
create trigger dbwebhook_notifications_insert_push
after insert on public.notifications
for each row
execute function supabase_functions.http_request(
  'http://host.docker.internal:54321/functions/v1/send-notification-push',
  'POST',
  '{"Content-Type":"application/json","Authorization":"Bearer <SERVICE_ROLE_KEY>"}',
  '{}',
  '10000'
);
```

##### 4. Serve the Edge Functions

```sh
supabase functions serve --env-file supabase/.env.local
```

##### 5. Get packages

```sh
flutter pub get
```

##### 6. Run code generation

```sh
dart run build_runner build --delete-conflicting-outputs
```

##### 7. Run the App

```sh
flutter run --flavor development --dart-define-from-file=.env.local
```

### Tools

#### Meme Template Uploader

This tool helps uploading meme templates to the storage and linking them to the database making it possible for users to use images as a template for their memes.

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

### Postrequisites

#### Push Notifications Setup

1. In each remote branch, create a Database Webhook:
- Table: `public.notifications`
- Events: `INSERT`
- Type: Supabase Edge Functions
- Function: `send-notification-push`
- Add Auth Header: enabled, using that branch's `service_role` key
