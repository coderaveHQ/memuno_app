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

##### 3. Serve the Edge Functions

```sh
supabase functions serve --env-file supabase/.env.local --no-verify-jwt
```

##### 4. Run code generation

```sh
dart run build_runner build --delete-conflicting-outputs
```

##### 5. Run the App

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

