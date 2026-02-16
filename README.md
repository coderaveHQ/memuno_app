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

## Supabase Fehler: Custom Exceptions (RPC + Edge Functions)

Damit unsere App Fehler sauber mappen kann, sollten Custom Errors ein
einheitliches Format haben. Der Mapper liest bei Edge Functions JSON-Felder
wie `code`, `userMessage`, `message`, `details`, `meta`. Bei RPC/SQL nutzt
er `SQLSTATE` (`code`) und die Felder `message`/`detail`/`hint`.

### Edge Functions (Deno)

- **Pflicht**: HTTP-Status != 2xx
- **Body**: JSON mit `code` + `userMessage` (deutscher Satz)
- Optional: `details`, `meta`

Beispiel:

```ts
// supabase/functions/my-function/index.ts
return new Response(
  JSON.stringify({
    code: "not_enough_credits",
    userMessage: "Du hast nicht genug Credits.",
    details: { required: 10, available: 3 },
    meta: { feature: "credits" },
  }),
  { status: 402, headers: { "Content-Type": "application/json" } },
);
```

**Wie es gemappt wird**
- `userMessage` → direkt als Nutzertext in der App
- `code` → optional für internes Tracking oder spätere i18n

### RPC / SQL (Postgres)

- **Pflicht**: `SQLSTATE` setzen (`errcode`)
- **Empfehlung**: Für generische DB-Fehler etablierte Codes nutzen
  z. B. `23505` (Unique Violation), `23503` (FK Violation), `22001` (too long)
- **Custom Fehler**: `P0001` nutzen (raise exception), Message/Detail setzen

Beispiel (Custom Error mit P0001):

```sql
raise exception 'not_enough_credits'
  using errcode = 'P0001',
        detail = 'Du hast nicht genug Credits.',
        hint = 'credits';
```

**Wie es gemappt wird**
- `errcode` → bestimmt den Failure-Typ (Postgres/Database)
- `detail`/`hint` → fuer Logs; in der UI nutzen wir weiterhin
  den vordefinierten deutschen Text, falls vorhanden

### Konventionen (kurz)

- `code`: `lower_snake_case` (z. B. `invalid_coupon`)
- `userMessage`: kompletter deutscher Satz für die UI (Edge Functions)
- `details`/`meta`: strukturierte Daten für Debug/Analytics

https://pub.dev/packages/zentoast
