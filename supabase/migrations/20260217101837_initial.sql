-- -----------------------------------------------------------------------------
-- Shared utility functions
-- -----------------------------------------------------------------------------

create function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new."updated_at" := now();
  return new;
end;
$$;

create function public.generate_friendship_code()
returns text
language plpgsql
set search_path = public
as $$
declare
  v_code text;
begin
  v_code := lpad((floor(random() * 100000000))::int::text, 8, '0');
  return v_code;
end;
$$;

-- -----------------------------------------------------------------------------
-- API payload and domain types
-- -----------------------------------------------------------------------------

create type public.user_details as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_list_page_item as (
  "user" public.friendship_list_page_item_user,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_list_page as (
  "items" public.friendship_list_page_item[],
  "next_cursor_name" text,
  "next_cursor_id" uuid
);

create type public.friendship_request_status
  as enum ('pending', 'accepted', 'declined', 'canceled');

create type public.friendship_request_direction
  as enum (
    'outgoing',
    'incoming'
  );

create type public.friendship_request_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_request_list_page_item as (
  "id" uuid,
  "status" public.friendship_request_status,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "direction" public.friendship_request_direction,
  "user" public.friendship_request_list_page_item_user
);

create type public.friendship_request_list_page as (
  "items" public.friendship_request_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.meme_template_list_page_item as (
  "id" uuid,
  "image_path" text,
  "aspect_ratio" double precision,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_template_list_page as (
  "items" public.meme_template_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.notification_type
  as enum (
    'friendship_request_sent',
    'friendship_request_accepted',
    'meme_received',
    'meme_laughed'
  );

create type public.notification_list_page_item as (
  "id" uuid,
  "type" public.notification_type,
  "data" jsonb,
  "is_read" boolean,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.notification_list_page as (
  "items" public.notification_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.feed_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.feed_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.feed_list_page_item as (
  "meme" public.feed_list_page_item_meme,
  "user" public.feed_list_page_item_user
);

create type public.feed_list_page as (
  "items" public.feed_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.meme_details_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_details as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean,
  "user" public.meme_details_user
);

create type public.meme_laugh_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_laugh_list_page_item as (
  "user" public.meme_laugh_list_page_item_user,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_laugh_list_page as (
  "items" public.meme_laugh_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_user_id" uuid
);

create type public.push_token_deactivation_reason
  as enum (
    'signed_out',
    'token_rotated',
    'permission_revoked',
    'send_invalid',
    'account_deleted',
    'cleanup'
  );

create type public.push_platform
  as enum ('ios', 'android');

create type public.push_preview_status
  as enum ('pending', 'ready', 'failed');

-- -----------------------------------------------------------------------------
-- Core tables
-- -----------------------------------------------------------------------------

create table public.users (
  "id" uuid not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  "name" text not null,
  "friendship_code" text not null,
  constraint pk_users primary key ("id"),
  constraint uq_users__friendship_code unique ("friendship_code"),
  constraint fk_users__id__auth_users__id
    foreign key ("id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_users__name_length
    check (length("name") >= 2 and length("name") <= 64),
  constraint ck_users__friendship_code_format
    check ("friendship_code" ~ '^[0-9]{8}$')
);

create table public.friendships (
  "user_id" uuid not null,
  "friend_id" uuid not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_friendships primary key ("user_id", "friend_id"),
  constraint fk_friendships__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint fk_friendships__friend_id__auth_users__id
    foreign key ("friend_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_friendships__neq_user_ids
    check ("user_id" <> "friend_id")
);

create table public.friendship_requests (
  "id" uuid not null default gen_random_uuid(),
  "requester_id" uuid not null,
  "addressee_id" uuid not null,
  "pair_low" uuid generated always as (least("requester_id", "addressee_id")) stored,
  "pair_high" uuid generated always as (greatest("requester_id", "addressee_id")) stored,
  "status" public.friendship_request_status not null default 'pending',
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_friendship_requests primary key ("id"),
  constraint fk_friendship_requests__requester_id__auth_users__id
    foreign key ("requester_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint fk_friendship_requests__addressee_id__auth_users__id
    foreign key ("addressee_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_friendship_requests__neq_user_ids
    check ("requester_id" <> "addressee_id")
);

create table public.meme_templates (
  "id" uuid not null default gen_random_uuid(),
  "image_path" text not null,
  "aspect_ratio" double precision not null,
  "tags" text[] not null default '{}'::text[],
  "is_active" boolean not null default true,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_meme_templates primary key ("id"),
  constraint uq_meme_templates__image_path unique ("image_path"),
  constraint ck_meme_templates__positive_aspect_ratio
    check ("aspect_ratio" > 0)
);

create table public.memes (
  "id" uuid not null default gen_random_uuid(),
  "user_id" uuid not null,
  "template_id" uuid,
  "image_path" text not null,
  "push_image_path" text,
  "push_preview_status" public.push_preview_status not null default 'pending',
  "aspect_ratio" double precision not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_memes primary key ("id"),
  constraint uq_memes__image_path unique ("image_path"),
  constraint uq_memes__push_image_path unique ("push_image_path"),
  constraint fk_memes__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint fk_memes__template_id__meme_templates__id
    foreign key ("template_id") references public.meme_templates ("id")
    on update cascade on delete restrict,
  constraint ck_memes__image_path_not_empty
    check (length(trim("image_path")) > 0),
  constraint ck_memes__push_image_path_not_empty
    check ("push_image_path" is null or length(trim("push_image_path")) > 0),
  constraint ck_memes__positive_aspect_ratio
    check ("aspect_ratio" > 0)
);

create table public.meme_recipients (
  "meme_id" uuid not null,
  "user_id" uuid not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_meme_recipients primary key ("meme_id", "user_id"),
  constraint fk_meme_recipients__meme_id__memes__id
    foreign key ("meme_id") references public.memes ("id")
    on update cascade on delete cascade,
  constraint fk_meme_recipients__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade
);

create table public.meme_laughs (
  "meme_id" uuid not null,
  "user_id" uuid not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_meme_laughs primary key ("meme_id", "user_id"),
  constraint fk_meme_laughs__meme_id__memes__id
    foreign key ("meme_id") references public.memes ("id")
    on update cascade on delete cascade,
  constraint fk_meme_laughs__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade
);

create table public.push_device_tokens (
  "id" uuid not null default gen_random_uuid(),
  "user_id" uuid not null,
  "installation_id" text not null,
  "fcm_token" text not null,
  "platform" public.push_platform not null,
  "language_code" text not null,
  "country_code" text,
  "is_active" boolean not null default true,
  "deactivation_reason" public.push_token_deactivation_reason,
  "deactivated_at" timestamptz,
  "last_seen_at" timestamptz not null default now(),
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_push_device_tokens primary key ("id"),
  constraint uq_push_device_tokens__fcm_token unique ("fcm_token"),
  constraint fk_push_device_tokens__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_push_device_tokens__installation_id_not_empty
    check (length(trim("installation_id")) > 0),
  constraint ck_push_device_tokens__fcm_token_not_empty
    check (length(trim("fcm_token")) > 0),
  constraint ck_push_device_tokens__language_code_format
    check ("language_code" ~ '^[a-z]{2}$'),
  constraint ck_push_device_tokens__country_code_format
    check ("country_code" is null or "country_code" ~ '^[A-Z]{2}$'),
  constraint ck_push_device_tokens__deactivation_consistency
    check (
      ("is_active" = true and "deactivation_reason" is null and "deactivated_at" is null)
      or ("is_active" = false and "deactivation_reason" is not null and "deactivated_at" is not null)
    )
);

create table public.notifications (
  "id" uuid not null default gen_random_uuid(),
  "recipient_id" uuid not null,
  "type" public.notification_type not null,
  "data" jsonb not null,
  "is_read" boolean not null default false,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_notifications primary key ("id"),
  constraint fk_notifications__recipient_id__auth_users__id
    foreign key ("recipient_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_notifications__data_shape
    check (
      case "type"
        when 'friendship_request_sent' then
          jsonb_typeof("data") = 'object'
          and jsonb_typeof("data"->'actor_id') = 'string'
          and jsonb_typeof("data"->'actor_name') = 'string'
          and jsonb_typeof("data"->'actor_friendship_code') = 'string'
          and jsonb_typeof("data"->'request_id') = 'string'
          and ("data"->>'actor_friendship_code') ~ '^[0-9]{8}$'
          and "data" ? 'route_tab'
          and ("data"->>'route_tab') = 'requests'
        when 'friendship_request_accepted' then
          jsonb_typeof("data") = 'object'
          and jsonb_typeof("data"->'actor_id') = 'string'
          and jsonb_typeof("data"->'actor_name') = 'string'
          and jsonb_typeof("data"->'actor_friendship_code') = 'string'
          and jsonb_typeof("data"->'request_id') = 'string'
          and ("data"->>'actor_friendship_code') ~ '^[0-9]{8}$'
          and "data" ? 'route_tab'
          and ("data"->>'route_tab') = 'friendships'
        when 'meme_received' then
          jsonb_typeof("data") = 'object'
          and jsonb_typeof("data"->'actor_id') = 'string'
          and jsonb_typeof("data"->'actor_name') = 'string'
          and jsonb_typeof("data"->'meme_id') = 'string'
          and "data" ? 'push_image_path'
          and (
            ("data"->'push_image_path') = 'null'::jsonb
            or (
              jsonb_typeof("data"->'push_image_path') = 'string'
              and length(trim("data"->>'push_image_path')) > 0
            )
          )
          and jsonb_typeof("data"->'aspect_ratio') = 'number'
          and ("data"->>'aspect_ratio')::double precision > 0
          and "data" ? 'route_tab'
          and ("data"->'route_tab') = 'null'::jsonb
        when 'meme_laughed' then
          jsonb_typeof("data") = 'object'
          and jsonb_typeof("data"->'actor_id') = 'string'
          and jsonb_typeof("data"->'actor_name') = 'string'
          and jsonb_typeof("data"->'meme_id') = 'string'
          and "data" ? 'push_image_path'
          and (
            ("data"->'push_image_path') = 'null'::jsonb
            or (
              jsonb_typeof("data"->'push_image_path') = 'string'
              and length(trim("data"->>'push_image_path')) > 0
            )
          )
          and jsonb_typeof("data"->'aspect_ratio') = 'number'
          and ("data"->>'aspect_ratio')::double precision > 0
          and "data" ? 'route_tab'
          and ("data"->'route_tab') = 'null'::jsonb
        else false
      end
    )
  );

create table public.notification_push_templates (
  "notification_type" public.notification_type not null,
  "language_code" text not null,
  "country_code" text,
  "title" text,
  "message" text not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint uq_notification_push_templates_type_locale
    unique nulls not distinct ("notification_type", "language_code", "country_code"),
  constraint ck_notification_push_templates__language_code_format
    check ("language_code" ~ '^[a-z]{2}$'),
  constraint ck_notification_push_templates__country_code_format
    check ("country_code" is null or "country_code" ~ '^[A-Z]{2}$'),
  constraint ck_notification_push_templates__title_not_empty
    check ("title" is null or length(trim("title")) > 0),
  constraint ck_notification_push_templates__message_not_empty
    check (length(trim("message")) > 0)
);

insert into public.notification_push_templates (
  "notification_type",
  "language_code",
  "country_code",
  "title",
  "message"
)
values
  (
    'friendship_request_sent',
    'en',
    null,
    'New friendship request',
    '{sender_name} sent you a friendship request.'
  ),
  (
    'friendship_request_accepted',
    'en',
    null,
    'Friendship request accepted',
    '{sender_name} accepted your friendship request.'
  ),
  (
    'meme_received',
    'en',
    null,
    'New meme received',
    '{sender_name} sent you a meme.'
  ),
  (
    'meme_laughed',
    'en',
    null,
    'Your meme got a laugh',
    '{sender_name} laughed at your meme.'
  ),
  (
    'friendship_request_sent',
    'en',
    'US',
    'New friendship request',
    '{sender_name} sent you a friendship request.'
  ),
  (
    'friendship_request_accepted',
    'en',
    'US',
    'Friendship request accepted',
    '{sender_name} accepted your friendship request.'
  ),
  (
    'meme_received',
    'en',
    'US',
    'New meme received',
    '{sender_name} sent you a meme.'
  ),
  (
    'meme_laughed',
    'en',
    'US',
    'Your meme got a laugh',
    '{sender_name} laughed at your meme.'
  ),
  (
    'friendship_request_sent',
    'de',
    null,
    'Neue Freundschaftsanfrage',
    '{sender_name} hat dir eine Freundschaftsanfrage gesendet.'
  ),
  (
    'friendship_request_accepted',
    'de',
    null,
    'Freundschaftsanfrage angenommen',
    '{sender_name} hat deine Freundschaftsanfrage angenommen.'
  ),
  (
    'meme_received',
    'de',
    null,
    'Neues Meme erhalten',
    '{sender_name} hat dir ein Meme gesendet.'
  ),
  (
    'meme_laughed',
    'de',
    null,
    'Dein Meme brachte jemanden zum Lachen',
    '{sender_name} hat ueber dein Meme gelacht.'
  ),
  (
    'friendship_request_sent',
    'de',
    'DE',
    'Neue Freundschaftsanfrage',
    '{sender_name} hat dir eine Freundschaftsanfrage gesendet.'
  ),
  (
    'friendship_request_accepted',
    'de',
    'DE',
    'Freundschaftsanfrage angenommen',
    '{sender_name} hat deine Freundschaftsanfrage angenommen.'
  ),
  (
    'meme_received',
    'de',
    'DE',
    'Neues Meme erhalten',
    '{sender_name} hat dir ein Meme gesendet.'
  ),
  (
    'meme_laughed',
    'de',
    'DE',
    'Dein Meme brachte jemanden zum Lachen',
    '{sender_name} hat ueber dein Meme gelacht.'
  );

-- -----------------------------------------------------------------------------
-- Indexes for friendship request workflows
-- -----------------------------------------------------------------------------

create unique index friendship_requests_one_pending_per_pair
on public.friendship_requests ("pair_low", "pair_high")
where "status" = 'pending';

create index friendship_requests_inbox_pending_idx
on public.friendship_requests ("addressee_id")
where "status" = 'pending';

create index friendship_requests_outbox_pending_idx
on public.friendship_requests ("requester_id")
where "status" = 'pending';

create index friendship_requests_pair_pending_lookup_idx
on public.friendship_requests ("requester_id", "addressee_id")
where "status" = 'pending';

create index meme_templates_tags_idx
on public.meme_templates
using gin ("tags");

create index meme_templates_created_at_id_idx
on public.meme_templates ("created_at" desc, "id" desc);

create index memes_created_at_id_idx
on public.memes ("created_at" desc, "id" desc);

create index meme_recipients_user_id_meme_id_idx
on public.meme_recipients ("user_id", "meme_id");

create index meme_laughs_user_id_meme_id_idx
on public.meme_laughs ("user_id", "meme_id");

create index meme_laughs_meme_id_created_at_user_id_idx
on public.meme_laughs ("meme_id", "created_at" desc, "user_id" desc);

create unique index push_device_tokens_one_active_per_installation_idx
on public.push_device_tokens ("installation_id")
where "is_active" = true;

create index push_device_tokens_user_active_last_seen_idx
on public.push_device_tokens ("user_id", "is_active", "last_seen_at" desc);

create index push_device_tokens_cleanup_idx
on public.push_device_tokens ("is_active", "deactivated_at")
where "is_active" = false;

create index notifications_recipient_created_at_id_idx
on public.notifications ("recipient_id", "created_at" desc, "id" desc);

create index notifications_recipient_unread_created_at_id_idx
on public.notifications ("recipient_id", "created_at" desc, "id" desc)
where "is_read" = false;

create unique index notifications_meme_received_recipient_meme_id_uidx
on public.notifications ("recipient_id", ("data"->>'meme_id'))
where "type" = 'meme_received';

-- -----------------------------------------------------------------------------
-- Friendship synchronization trigger function
-- -----------------------------------------------------------------------------

create function public.sync_friendships_from_accepted_request()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new."status" <> 'accepted' then
    return new;
  end if;

  if tg_op = 'UPDATE' and old."status" = 'accepted' then
    return new;
  end if;

  insert into public.friendships ("user_id", "friend_id")
  values (new."requester_id", new."addressee_id"), (new."addressee_id", new."requester_id")
  on conflict do nothing;

  return new;
end;
$$;

create function public.create_notification_on_friendship_request_sent()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_actor public.users;
begin
  if new."status" <> 'pending' then
    return new;
  end if;

  select *
  into v_actor
  from public.users u
  where u."id" = new."requester_id";

  if v_actor."id" is null then
    raise exception 'requester profile not found for friendship request notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    new."addressee_id",
    'friendship_request_sent',
    jsonb_build_object(
      'actor_id',
      v_actor."id",
      'actor_name',
      v_actor."name",
      'actor_friendship_code',
      v_actor."friendship_code",
      'request_id',
      new."id",
      'route_tab',
      'requests'
    )
  );

  return new;
end;
$$;

create function public.create_notification_on_friendship_request_accepted()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_actor public.users;
begin
  if new."status" <> 'accepted' or old."status" = new."status" then
    return new;
  end if;

  select *
  into v_actor
  from public.users u
  where u."id" = new."addressee_id";

  if v_actor."id" is null then
    raise exception 'addressee profile not found for friendship accepted notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    new."requester_id",
    'friendship_request_accepted',
    jsonb_build_object(
      'actor_id',
      v_actor."id",
      'actor_name',
      v_actor."name",
      'actor_friendship_code',
      v_actor."friendship_code",
      'request_id',
      new."id",
      'route_tab',
      'friendships'
    )
  );

  return new;
end;
$$;

create function public.create_notifications_on_meme_preview_resolved()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_actor_name text;
  v_push_image_path text;
begin
  if old."push_preview_status" <> 'pending' then
    return new;
  end if;

  if new."push_preview_status" = old."push_preview_status" then
    return new;
  end if;

  if new."push_preview_status" not in ('ready', 'failed') then
    return new;
  end if;

  select u."name"
  into v_actor_name
  from public.users u
  where u."id" = new."user_id";

  if v_actor_name is null then
    raise exception 'meme creator profile not found for meme notification';
  end if;

  if new."push_preview_status" = 'ready' then
    v_push_image_path := nullif(trim(new."push_image_path"), '');
    if v_push_image_path is null then
      raise exception 'meme push_image_path not found for ready meme notification';
    end if;
  else
    v_push_image_path := null;
  end if;

  if new."aspect_ratio" is null or new."aspect_ratio" <= 0 then
    raise exception 'meme aspect_ratio not found for meme notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  select
    mr."user_id",
    'meme_received',
    jsonb_build_object(
      'actor_id',
      new."user_id",
      'actor_name',
      v_actor_name,
      'meme_id',
      new."id",
      'push_image_path',
      v_push_image_path,
      'aspect_ratio',
      new."aspect_ratio",
      'route_tab',
      to_jsonb(null::text)
    )
  from public.meme_recipients mr
  where mr."meme_id" = new."id"
  on conflict do nothing;

  return new;
end;
$$;

create function public.create_notification_on_meme_laughed()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_actor_name text;
  v_meme_owner_id uuid;
  v_push_image_path text;
  v_meme_aspect_ratio double precision;
begin
  select u."name"
  into v_actor_name
  from public.users u
  where u."id" = new."user_id";

  if v_actor_name is null then
    raise exception 'meme laugh actor profile not found for meme_laughed notification';
  end if;

  select
    m."user_id",
    nullif(trim(m."push_image_path"), ''),
    m."aspect_ratio"
  into
    v_meme_owner_id,
    v_push_image_path,
    v_meme_aspect_ratio
  from public.memes m
  where m."id" = new."meme_id";

  if v_meme_owner_id is null then
    raise exception 'meme not found for meme_laughed notification';
  end if;

  if v_meme_aspect_ratio is null or v_meme_aspect_ratio <= 0 then
    raise exception 'meme aspect_ratio not found for meme_laughed notification';
  end if;

  if v_meme_owner_id = new."user_id" then
    return new;
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    v_meme_owner_id,
    'meme_laughed',
    jsonb_build_object(
      'actor_id',
      new."user_id",
      'actor_name',
      v_actor_name,
      'meme_id',
      new."meme_id",
      'push_image_path',
      v_push_image_path,
      'aspect_ratio',
      v_meme_aspect_ratio,
      'route_tab',
      to_jsonb(null::text)
    )
  );

  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Timestamp maintenance triggers
-- -----------------------------------------------------------------------------

create trigger trg_users__touch_updated_at
before update on public.users
for each row
execute function public.touch_updated_at();

create trigger trg_friendships__touch_updated_at
before update on public.friendships
for each row
execute function public.touch_updated_at();

create trigger trg_friendship_requests__touch_updated_at
before update on public.friendship_requests
for each row
execute function public.touch_updated_at();

create trigger trg_meme_templates__touch_updated_at
before update on public.meme_templates
for each row
execute function public.touch_updated_at();

create trigger trg_memes__touch_updated_at
before update on public.memes
for each row
execute function public.touch_updated_at();

create trigger trg_meme_recipients__touch_updated_at
before update on public.meme_recipients
for each row
execute function public.touch_updated_at();

create trigger trg_meme_laughs__touch_updated_at
before update on public.meme_laughs
for each row
execute function public.touch_updated_at();

create trigger trg_push_device_tokens__touch_updated_at
before update on public.push_device_tokens
for each row
execute function public.touch_updated_at();

create trigger trg_notifications__touch_updated_at
before update on public.notifications
for each row
execute function public.touch_updated_at();

create trigger trg_notification_push_templates__touch_updated_at
before update on public.notification_push_templates
for each row
execute function public.touch_updated_at();

create trigger trg_friendship_requests__sync_friendships_on_accepted
after insert or update of "status" on public.friendship_requests
for each row
execute function public.sync_friendships_from_accepted_request();

create trigger trg_friendship_requests__create_notification_on_insert
after insert on public.friendship_requests
for each row
execute function public.create_notification_on_friendship_request_sent();

create trigger trg_friendship_requests__create_notification_on_accepted
after update of "status" on public.friendship_requests
for each row
execute function public.create_notification_on_friendship_request_accepted();

create trigger trg_memes__create_notifications_on_preview_resolved
after update of "push_preview_status" on public.memes
for each row
execute function public.create_notifications_on_meme_preview_resolved();

create trigger trg_meme_laughs__create_notification_on_insert
after insert on public.meme_laughs
for each row
execute function public.create_notification_on_meme_laughed();

-- -----------------------------------------------------------------------------
-- Meme access helper functions
-- -----------------------------------------------------------------------------

create function public.is_meme_creator(
  p_meme_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.memes m
    where m."id" = p_meme_id
      and m."user_id" = p_user_id
  );
$$;

create function public.is_meme_recipient(
  p_meme_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.meme_recipients mr
    where mr."meme_id" = p_meme_id
      and mr."user_id" = p_user_id
  );
$$;

create function public.can_view_meme(
  p_meme_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_meme_creator(p_meme_id, p_user_id)
     or public.is_meme_recipient(p_meme_id, p_user_id);
$$;

-- -----------------------------------------------------------------------------
-- Row-level security and policies
-- -----------------------------------------------------------------------------

alter table public.users enable row level security;
alter table public.friendships enable row level security;
alter table public.friendship_requests enable row level security;
alter table public.meme_templates enable row level security;
alter table public.memes enable row level security;
alter table public.meme_recipients enable row level security;
alter table public.meme_laughs enable row level security;
alter table public.push_device_tokens enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_push_templates enable row level security;

create policy "users:select:self:authenticated"
on public.users
for select
to authenticated
using (true);

create policy "users:update:self:authenticated"
on public.users
for update
to authenticated
using ("id" = (select auth.uid()))
with check ("id" = (select auth.uid()));

create policy "friendships:select:self:authenticated"
on public.friendships
for select
to authenticated
using ("user_id" = (select auth.uid()));

create policy "friendships:insert:self:authenticated"
on public.friendships
for insert
to authenticated
with check ("user_id" = (select auth.uid()));

create policy "friendships:delete:self:authenticated"
on public.friendships
for delete
to authenticated
using ("user_id" = (select auth.uid()));

create policy "friendship_requests:select:participant:authenticated"
on public.friendship_requests
for select
to authenticated
using (
  "requester_id" = (select auth.uid())
  or "addressee_id" = (select auth.uid())
);

create policy "friendship_requests:insert:requester:authenticated"
on public.friendship_requests
for insert
to authenticated
with check ("requester_id" = (select auth.uid()));

create policy "friendship_requests:update:participant:authenticated"
on public.friendship_requests
for update
to authenticated
using (
  "requester_id" = (select auth.uid())
  or "addressee_id" = (select auth.uid())
)
with check (
  "requester_id" = (select auth.uid())
  or "addressee_id" = (select auth.uid())
);

create policy "meme_templates:select:active:authenticated"
on public.meme_templates
for select
to authenticated
using ("is_active" = true);

create policy "memes:select:owner_or_recipient:authenticated"
on public.memes
for select
to authenticated
using (
  "user_id" = (select auth.uid())
  or public.is_meme_recipient(public.memes."id", (select auth.uid()))
);

create policy "memes:insert:owner:authenticated"
on public.memes
for insert
to authenticated
with check ("user_id" = (select auth.uid()));

create policy "meme_recipients:select:self:authenticated"
on public.meme_recipients
for select
to authenticated
using ("user_id" = (select auth.uid()));

create policy "meme_recipients:insert:owner:authenticated"
on public.meme_recipients
for insert
to authenticated
with check (
  exists (
    select 1
    from public.memes m
    where m."id" = public.meme_recipients."meme_id"
      and m."user_id" = (select auth.uid())
  )
);

create policy "meme_laughs:select:viewable_meme:authenticated"
on public.meme_laughs
for select
to authenticated
using (public.can_view_meme(public.meme_laughs."meme_id", (select auth.uid())));

create policy "meme_laughs:insert:self_viewable_meme:authenticated"
on public.meme_laughs
for insert
to authenticated
with check (
  "user_id" = (select auth.uid())
  and public.can_view_meme(public.meme_laughs."meme_id", (select auth.uid()))
  and not public.is_meme_creator(
    public.meme_laughs."meme_id",
    (select auth.uid())
  )
);

create policy "meme_laughs:delete:self:authenticated"
on public.meme_laughs
for delete
to authenticated
using ("user_id" = (select auth.uid()));

create policy "push_device_tokens:select:self:authenticated"
on public.push_device_tokens
for select
to authenticated
using ("user_id" = (select auth.uid()));

create policy "push_device_tokens:insert:self:authenticated"
on public.push_device_tokens
for insert
to authenticated
with check ("user_id" = (select auth.uid()));

create policy "push_device_tokens:update:self:authenticated"
on public.push_device_tokens
for update
to authenticated
using ("user_id" = (select auth.uid()))
with check ("user_id" = (select auth.uid()));

create policy "push_device_tokens:delete:self:authenticated"
on public.push_device_tokens
for delete
to authenticated
using ("user_id" = (select auth.uid()));

create policy "notifications:select:recipient:authenticated"
on public.notifications
for select
to authenticated
using ("recipient_id" = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- Auth signup provisioning
-- -----------------------------------------------------------------------------

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
  v_code text;
begin
  v_name := new.raw_user_meta_data->'initial_data'->>'name';

  if v_name is null then
    raise exception 'missing user name in raw_user_meta_data.initial_data.name';
  end if;

  loop
    v_code := public.generate_friendship_code();
    exit when not exists (
      select 1
      from public.users u
      where u."friendship_code" = v_code
    );
  end loop;

  insert into public.users ("id", "name", "friendship_code")
  values (new."id", v_name, v_code);

  return new;
end;
$$;

create trigger trg_auth_users__after_insert__handle_new_user
after insert on auth.users
for each row
execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- User/details RPCs
-- -----------------------------------------------------------------------------

create function public.update_current_user_name(
  p_name text
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user_id uuid;
begin
  v_user_id := (select auth.uid());

  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  update public.users
  set "name" = p_name
  where "id" = v_user_id;

  if not found then
    raise exception 'current user details not found';
  end if;
end;
$$;

create function public.get_users_profile(
  p_user_id uuid
)
returns public.user_details
language sql
stable
security invoker
set search_path = public
as $$
  select row(
    u."id",
    u."name",
    u."friendship_code",
    u."created_at",
    u."updated_at"
  )::public.user_details
  from public.users u
  where u."id" = p_user_id
  limit 1;
$$;

-- -----------------------------------------------------------------------------
-- Push token RPCs
-- -----------------------------------------------------------------------------

create function public.push_token_upsert(
  p_installation_id text,
  p_fcm_token text,
  p_platform public.push_platform,
  p_language_code text,
  p_country_code text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_installation_id text;
  v_fcm_token text;
  v_language_code text;
  v_country_code text;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_installation_id := nullif(trim(p_installation_id), '');
  if v_installation_id is null then
    raise exception 'installation_id is required';
  end if;

  v_fcm_token := nullif(trim(p_fcm_token), '');
  if v_fcm_token is null then
    raise exception 'fcm_token is required';
  end if;

  v_language_code := lower(nullif(trim(p_language_code), ''));
  if v_language_code is null or v_language_code !~ '^[a-z]{2}$' then
    raise exception 'invalid language_code format';
  end if;

  v_country_code := upper(nullif(trim(p_country_code), ''));
  if v_country_code is not null and v_country_code !~ '^[A-Z]{2}$' then
    raise exception 'invalid country_code format';
  end if;

  update public.push_device_tokens
  set
    "is_active" = false,
    "deactivation_reason" = 'token_rotated',
    "deactivated_at" = now()
  where "installation_id" = v_installation_id
    and "is_active" = true
    and "fcm_token" <> v_fcm_token;

  insert into public.push_device_tokens (
    "user_id",
    "installation_id",
    "fcm_token",
    "platform",
    "language_code",
    "country_code",
    "is_active",
    "deactivation_reason",
    "deactivated_at",
    "last_seen_at"
  )
  values (
    v_user_id,
    v_installation_id,
    v_fcm_token,
    p_platform,
    v_language_code,
    v_country_code,
    true,
    null,
    null,
    now()
  )
  on conflict ("fcm_token")
  do update
  set
    "user_id" = excluded."user_id",
    "installation_id" = excluded."installation_id",
    "platform" = excluded."platform",
    "language_code" = excluded."language_code",
    "country_code" = excluded."country_code",
    "is_active" = true,
    "deactivation_reason" = null,
    "deactivated_at" = null,
    "last_seen_at" = now();
end;
$$;

create function public.push_token_deactivate_current_device(
  p_installation_id text,
  p_reason public.push_token_deactivation_reason default 'signed_out'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_installation_id text;
  v_reason public.push_token_deactivation_reason;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_installation_id := nullif(trim(p_installation_id), '');
  if v_installation_id is null then
    raise exception 'installation_id is required';
  end if;

  v_reason := coalesce(p_reason, 'signed_out');

  update public.push_device_tokens
  set
    "is_active" = false,
    "deactivation_reason" = v_reason,
    "deactivated_at" = now()
  where "user_id" = v_user_id
    and "installation_id" = v_installation_id
    and "is_active" = true;
end;
$$;

create function public.push_tokens_cleanup_inactive(
  p_older_than interval default interval '90 days'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted integer;
  v_cutoff timestamptz;
begin
  if p_older_than is null or p_older_than <= interval '0' then
    raise exception 'older_than must be greater than zero';
  end if;

  v_cutoff := now() - p_older_than;

  delete from public.push_device_tokens
  where "is_active" = false
    and coalesce("deactivated_at", "updated_at", "created_at") < v_cutoff;

  get diagnostics v_deleted = row_count;
  return v_deleted;
end;
$$;

-- -----------------------------------------------------------------------------
-- Notification list RPC
-- -----------------------------------------------------------------------------

create function public.notifications_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.notification_list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "user_id",
      nullif(trim(p_search), '') as "search_term"
  ),
  base as (
    select
      n."id",
      n."type",
      n."data",
      n."is_read",
      n."created_at",
      n."updated_at",
      lower(coalesce(n."data"->>'actor_name', '')) as "actor_name",
      coalesce(n."data"->>'actor_friendship_code', '') as "actor_friendship_code"
    from public.notifications n
    where n."recipient_id" = (select "user_id" from params)
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or "actor_name" like '%' || lower((select "search_term" from params)) || '%'
      or "actor_friendship_code" like '%' || (select "search_term" from params) || '%'
  ),
  ordered as (
    select
      row(
        "id",
        "type",
        "data",
        "is_read",
        "created_at",
        "updated_at"
      )::public.notification_list_page_item as "item",
      "created_at" as "sort_created_at",
      "id" as "sort_id"
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or ("sort_created_at", "sort_id") < (p_cursor_created_at, p_cursor_id)
    )
    order by "sort_created_at" desc, "sort_id" desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      "sort_created_at" as "next_created_at",
      "sort_id" as "next_id"
    from paged
    order by "sort_created_at" asc, "sort_id" asc
    limit 1
  )
  select
    coalesce(
      array_agg(paged."item"),
      '{}'::public.notification_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Friendship list RPCs
-- -----------------------------------------------------------------------------

create function public.friendship_requests_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.friendship_request_list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "user_id",
      nullif(trim(p_search), '') as "search_term"
  ),
  base as (
    select
      r."id" as "request_id",
      r."status",
      r."created_at",
      r."updated_at",
      case
        when r."requester_id" = (select "user_id" from params)
          then 'outgoing'::public.friendship_request_direction
        else 'incoming'::public.friendship_request_direction
      end as "direction",
      case
        when r."requester_id" = (select "user_id" from params)
          then r."addressee_id"
        else r."requester_id"
      end as "other_user_id",
      case
        when r."requester_id" = (select "user_id" from params)
          then ua."name"
        else ur."name"
      end as "other_user_name",
      case
        when r."requester_id" = (select "user_id" from params)
          then ua."friendship_code"
        else ur."friendship_code"
      end as "other_user_friendship_code",
      case
        when r."requester_id" = (select "user_id" from params)
          then ua."created_at"
        else ur."created_at"
      end as "other_user_created_at",
      case
        when r."requester_id" = (select "user_id" from params)
          then ua."updated_at"
        else ur."updated_at"
      end as "other_user_updated_at"
    from public.friendship_requests r
    join public.users ur on ur."id" = r."requester_id"
    join public.users ua on ua."id" = r."addressee_id"
    where (
      r."requester_id" = (select "user_id" from params)
      or r."addressee_id" = (select "user_id" from params)
    )
      and r."status" = 'pending'
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("other_user_name") like '%' || lower((select "search_term" from params)) || '%'
      or "other_user_friendship_code" like '%' || (select "search_term" from params) || '%'
  ),
  ordered as (
    select
      row(
        "request_id",
        "status",
        "created_at",
        "updated_at",
        "direction",
        row(
          "other_user_id",
          "other_user_name",
          "other_user_friendship_code",
          "other_user_created_at",
          "other_user_updated_at"
        )::public.friendship_request_list_page_item_user
      )::public.friendship_request_list_page_item as "item",
      "created_at" as "sort_created_at",
      "request_id" as "sort_id"
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or ("sort_created_at", "sort_id") < (p_cursor_created_at, p_cursor_id)
    )
    order by "sort_created_at" desc, "sort_id" desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      "sort_created_at" as "next_created_at",
      "sort_id" as "next_id"
    from paged
    order by "sort_created_at" asc, "sort_id" asc
    limit 1
  )
  select
    coalesce(
      array_agg(paged."item"),
      '{}'::public.friendship_request_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.friendships_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_name text default null,
  p_cursor_id uuid default null
)
returns public.friendship_list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "user_id",
      nullif(trim(p_search), '') as "search_term"
  ),
  base as (
    select
      f."friend_id",
      u."name" as "friend_name",
      u."friendship_code" as "friendship_code",
      u."created_at" as "friend_created_at",
      u."updated_at" as "friend_updated_at",
      f."created_at",
      f."updated_at"
    from public.friendships f
    join public.users u on u."id" = f."friend_id"
    where f."user_id" = (select "user_id" from params)
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("friend_name") like '%' || lower((select "search_term" from params)) || '%'
      or "friendship_code" like '%' || (select "search_term" from params) || '%'
  ),
  ordered as (
    select
      row(
        row(
          "friend_id",
          "friend_name",
          "friendship_code",
          "friend_created_at",
          "friend_updated_at"
        )::public.friendship_list_page_item_user,
        "created_at",
        "updated_at"
      )::public.friendship_list_page_item as "item",
      lower("friend_name") as "sort_name",
      "friend_id" as "sort_id"
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_name is null
      or p_cursor_id is null
      or ("sort_name", "sort_id") > (lower(p_cursor_name), p_cursor_id)
    )
    order by "sort_name", "sort_id"
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      "sort_name" as "next_name",
      "sort_id" as "next_id"
    from paged
    order by "sort_name" desc, "sort_id" desc
    limit 1
  )
  select
    coalesce(
      array_agg(paged."item"),
      '{}'::public.friendship_list_page_item[]
    ) as "items",
    (select "next_name" from next_cursor) as "next_cursor_name",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Meme templates list RPC
-- -----------------------------------------------------------------------------

create function public.meme_templates_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.meme_template_list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select nullif(trim(p_search), '') as "search_term"
  ),
  base as (
    select
      t."id",
      t."image_path",
      t."aspect_ratio",
      t."created_at",
      t."updated_at"
    from public.meme_templates t
    where t."is_active" = true
      and (
        (select "search_term" from params) is null
        or exists (
          select 1
          from unnest(t."tags") as tag
          where tag ilike '%' || (select "search_term" from params) || '%'
        )
      )
  ),
  ordered as (
    select
      row(
        "id",
        "image_path",
        "aspect_ratio",
        "created_at",
        "updated_at"
      )::public.meme_template_list_page_item as "item",
      "created_at" as "sort_created_at",
      "id" as "sort_id"
    from base
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or ("sort_created_at", "sort_id") < (p_cursor_created_at, p_cursor_id)
    )
    order by "sort_created_at" desc, "sort_id" desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      "sort_created_at" as "next_created_at",
      "sort_id" as "next_id"
    from paged
    order by "sort_created_at" asc, "sort_id" asc
    limit 1
  )
  select
    coalesce(
      array_agg(paged."item"),
      '{}'::public.meme_template_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Feed list RPC
-- -----------------------------------------------------------------------------

create function public.feed_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.feed_list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "user_id"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      case
        when m."user_id" = (select "user_id" from params) then false
        else exists (
          select 1
          from public.meme_laughs ml
          where ml."meme_id" = m."id"
            and ml."user_id" = (select "user_id" from params)
        )
      end as "is_laughed",
      u."id" as "creator_user_id",
      u."name" as "creator_user_name",
      u."friendship_code" as "creator_user_friendship_code",
      u."created_at" as "creator_user_created_at",
      u."updated_at" as "creator_user_updated_at"
    from public.memes m
    join public.users u on u."id" = m."user_id"
    left join (
      select
        ml."meme_id",
        count(*) as "laugh_count"
      from public.meme_laughs ml
      group by ml."meme_id"
    ) lc on lc."meme_id" = m."id"
    where (
      m."user_id" = (select "user_id" from params)
      or exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."user_id" = (select "user_id" from params)
      )
    )
  ),
  ordered as (
    select
      row(
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.feed_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.feed_list_page_item_user
      )::public.feed_list_page_item as "item",
      "meme_created_at" as "sort_created_at",
      "meme_id" as "sort_id"
    from base
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or ("sort_created_at", "sort_id") < (p_cursor_created_at, p_cursor_id)
    )
    order by "sort_created_at" desc, "sort_id" desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      "sort_created_at" as "next_created_at",
      "sort_id" as "next_id"
    from paged
    order by "sort_created_at" asc, "sort_id" asc
    limit 1
  )
  select
    coalesce(
      array_agg(paged."item"),
      '{}'::public.feed_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Meme details RPCs
-- -----------------------------------------------------------------------------

create function public.meme_details_get(
  p_meme_id uuid
)
returns public.meme_details
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_details public.meme_details;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if not public.can_view_meme(p_meme_id, v_user_id) then
    raise exception 'meme not visible';
  end if;

  select
    m."id",
    m."created_at",
    m."updated_at",
    m."image_path",
    m."aspect_ratio",
    coalesce(lc."laugh_count", 0)::integer,
    case
      when m."user_id" = v_user_id then false
      else exists (
        select 1
        from public.meme_laughs ml
        where ml."meme_id" = m."id"
          and ml."user_id" = v_user_id
      )
    end,
    row(
      u."id",
      u."name",
      u."friendship_code",
      u."created_at",
      u."updated_at"
    )::public.meme_details_user
  into v_details
  from public.memes m
  join public.users u on u."id" = m."user_id"
  left join (
    select
      ml."meme_id",
      count(*) as "laugh_count"
    from public.meme_laughs ml
    group by ml."meme_id"
  ) lc on lc."meme_id" = m."id"
  where m."id" = p_meme_id
  limit 1;

  if v_details is null then
    raise exception 'meme not found';
  end if;

  return v_details;
end;
$$;

create function public.meme_laughs_list(
  p_meme_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_user_id uuid default null
)
returns public.meme_laugh_list_page
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if not public.can_view_meme(p_meme_id, v_user_id) then
    raise exception 'meme not visible';
  end if;

  return (
    with base as (
      select
        ml."user_id",
        ml."created_at" as "laugh_created_at",
        ml."updated_at" as "laugh_updated_at",
        u."name" as "user_name",
        u."friendship_code" as "user_friendship_code",
        u."created_at" as "user_created_at",
        u."updated_at" as "user_updated_at"
      from public.meme_laughs ml
      join public.users u on u."id" = ml."user_id"
      where ml."meme_id" = p_meme_id
    ),
    ordered as (
      select
        row(
          row(
            "user_id",
            "user_name",
            "user_friendship_code",
            "user_created_at",
            "user_updated_at"
          )::public.meme_laugh_list_page_item_user,
          "laugh_created_at",
          "laugh_updated_at"
        )::public.meme_laugh_list_page_item as "item",
        "laugh_created_at" as "sort_created_at",
        "user_id" as "sort_user_id"
      from base
    ),
    paged as (
      select *
      from ordered
      where (
        p_cursor_created_at is null
        or p_cursor_user_id is null
        or ("sort_created_at", "sort_user_id")
          < (p_cursor_created_at, p_cursor_user_id)
      )
      order by "sort_created_at" desc, "sort_user_id" desc
      limit coalesce(p_limit, 30)
    ),
    next_cursor as (
      select
        "sort_created_at" as "next_created_at",
        "sort_user_id" as "next_user_id"
      from paged
      order by "sort_created_at" asc, "sort_user_id" asc
      limit 1
    )
    select
      row(
        coalesce(
          array_agg(paged."item"),
          '{}'::public.meme_laugh_list_page_item[]
        ),
        (select "next_created_at" from next_cursor),
        (select "next_user_id" from next_cursor)
      )::public.meme_laugh_list_page
    from paged
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- Notification mutation RPCs
-- -----------------------------------------------------------------------------

create function public.notification_mark_read(
  p_notification_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_notification_id is null then
    raise exception 'notification_id is required';
  end if;

  update public.notifications
  set "is_read" = true,
      "updated_at" = now()
  where "id" = p_notification_id
    and "recipient_id" = v_user_id
    and "is_read" = false;
end;
$$;

create function public.notifications_mark_all_read()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_updated integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  update public.notifications
  set "is_read" = true,
      "updated_at" = now()
  where "recipient_id" = v_user_id
    and "is_read" = false;

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$$;

create function public.notifications_unread_count()
returns integer
language sql
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.notifications n
  where n."recipient_id" = (select auth.uid())
    and n."is_read" = false;
$$;

-- -----------------------------------------------------------------------------
-- Notification push dispatch webhook provisioning
-- -----------------------------------------------------------------------------

create extension if not exists pg_net with schema extensions;
create extension if not exists supabase_vault with schema vault;

create function public.get_required_vault_secret(
  p_secret_name text
)
returns text
language plpgsql
security definer
set search_path = public, vault
as $$
declare
  v_secret_value text;
begin
  select ds.decrypted_secret
  into v_secret_value
  from vault.decrypted_secrets ds
  where ds.name = p_secret_name
  order by ds.created_at desc
  limit 1;

  if v_secret_value is null then
    raise exception 'Vault secret "%" is required.', p_secret_name;
  end if;

  return v_secret_value;
end;
$$;

create function public.upsert_vault_secret(
  p_secret_name text,
  p_secret_value text,
  p_secret_description text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, vault
as $$
declare
  v_secret_id uuid;
begin
  select s.id
  into v_secret_id
  from vault.secrets s
  where s.name = p_secret_name
  limit 1;

  if v_secret_id is null then
    select vault.create_secret(
      p_secret_value,
      p_secret_name,
      p_secret_description,
      null
    )
    into v_secret_id;
  else
    perform vault.update_secret(
      v_secret_id,
      p_secret_value,
      p_secret_name,
      p_secret_description,
      null
    );
  end if;

  return v_secret_id;
end;
$$;

create function public.invoke_internal_edge_function(
  p_function_name text,
  p_payload jsonb default '{}'::jsonb,
  p_timeout_milliseconds integer default 10000
)
returns bigint
language plpgsql
security definer
set search_path = public, extensions, vault
as $$
declare
  v_base_url text;
  v_apikey text;
  v_request_id bigint;
begin
  v_base_url := public.get_required_vault_secret('edge_functions_base_url');
  v_apikey := public.get_required_vault_secret('edge_functions_apikey');

  select net.http_post(
    url := rtrim(v_base_url, '/') || '/functions/v1/' || p_function_name,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', v_apikey
    ),
    body := coalesce(p_payload, '{}'::jsonb),
    timeout_milliseconds := p_timeout_milliseconds
  )
  into v_request_id;

  return v_request_id;
end;
$$;

create function public.enqueue_generate_meme_push_preview()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.invoke_internal_edge_function(
    'generate-meme-push-preview',
    jsonb_build_object(
      'type', tg_op,
      'table', tg_table_name,
      'schema', tg_table_schema,
      'record', to_jsonb(new)
    )
  );

  return new;
end;
$$;

create function public.enqueue_send_notification_push()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.invoke_internal_edge_function(
    'send-notification-push',
    jsonb_build_object(
      'type', tg_op,
      'table', tg_table_name,
      'schema', tg_table_schema,
      'record', to_jsonb(new)
    )
  );

  return new;
end;
$$;

create trigger dbwebhook_memes_insert_generate_push_preview
after insert on public.memes
for each row
execute function public.enqueue_generate_meme_push_preview();

create trigger dbwebhook_notifications_insert_send_push
after insert on public.notifications
for each row
execute function public.enqueue_send_notification_push();

-- -----------------------------------------------------------------------------
-- Friendship mutation RPCs
-- -----------------------------------------------------------------------------

create function public.friendship_request_create(
  p_addressee_friendship_code text
)
returns public.friendship_request_list_page_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requester_id uuid := (select auth.uid());
  v_addressee_id uuid;
  v_req public.friendship_requests;
  v_result public.friendship_request_list_page_item;
begin
  if v_requester_id is null then
    raise exception 'not authenticated';
  end if;

  if p_addressee_friendship_code is null then
    raise exception 'friendship_code is required';
  end if;

  if p_addressee_friendship_code !~ '^[0-9]{8}$' then
    raise exception 'invalid friendship_code format';
  end if;

  select u."id"
  into v_addressee_id
  from public.users u
  where u."friendship_code" = p_addressee_friendship_code;

  if v_addressee_id is null then
    raise exception 'user not found';
  end if;

  if v_requester_id = v_addressee_id then
    raise exception 'cannot request friendship with yourself';
  end if;

  if exists (
    select 1
    from public.friendships f
    where f."user_id" = v_requester_id
      and f."friend_id" = v_addressee_id
  ) then
    raise exception 'users are already friends';
  end if;

  if exists (
    select 1
    from public.friendship_requests r
    where r."pair_low" = least(v_requester_id, v_addressee_id)
      and r."pair_high" = greatest(v_requester_id, v_addressee_id)
      and r."status" = 'pending'
  ) then
    raise exception 'friendship request already pending';
  end if;

  insert into public.friendship_requests ("requester_id", "addressee_id")
  values (v_requester_id, v_addressee_id)
  returning * into v_req;

  select
    r."id",
    r."status",
    r."created_at",
    r."updated_at",
    case
      when r."requester_id" = v_requester_id
        then 'outgoing'::public.friendship_request_direction
      else 'incoming'::public.friendship_request_direction
    end,
    row(
      case
        when r."requester_id" = v_requester_id then r."addressee_id"
        else r."requester_id"
      end,
      case
        when r."requester_id" = v_requester_id then ua."name"
        else ur."name"
      end,
      case
        when r."requester_id" = v_requester_id then ua."friendship_code"
        else ur."friendship_code"
      end,
      case
        when r."requester_id" = v_requester_id then ua."created_at"
        else ur."created_at"
      end,
      case
        when r."requester_id" = v_requester_id then ua."updated_at"
        else ur."updated_at"
      end
    )::public.friendship_request_list_page_item_user
  into v_result
  from public.friendship_requests r
  join public.users ur on ur."id" = r."requester_id"
  join public.users ua on ua."id" = r."addressee_id"
  where r."id" = v_req."id";

  if v_result is null then
    raise exception 'failed to create friendship request';
  end if;

  return v_result;
end;
$$;

create function public.friendship_request_accept(
  p_request_id uuid
)
returns public.friendship_list_page_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_addressee_id uuid := (select auth.uid());
  v_requester_id uuid;
  v_result public.friendship_list_page_item;
begin
  if v_addressee_id is null then
    raise exception 'not authenticated';
  end if;

  if p_request_id is null then
    raise exception 'request_id is required';
  end if;

  update public.friendship_requests
  set "status" = 'accepted', "updated_at" = now()
  where "id" = p_request_id
    and "addressee_id" = v_addressee_id
    and "status" = 'pending'
  returning "requester_id"
  into v_requester_id;

  if v_requester_id is null then
    raise exception 'no pending request';
  end if;

  select
    row(
      u."id",
      u."name",
      u."friendship_code",
      u."created_at",
      u."updated_at"
    )::public.friendship_list_page_item_user,
    f."created_at",
    f."updated_at"
  into v_result
  from public.users u
  join public.friendships f
    on f."user_id" = v_addressee_id
   and f."friend_id" = u."id"
  where u."id" = v_requester_id
  limit 1;

  if v_result is null then
    raise exception 'failed to load accepted friendship payload';
  end if;

  return v_result;
end;
$$;

create function public.friendship_request_decline(
  p_request_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_addressee_id uuid := (select auth.uid());
  v_updated int;
begin
  if v_addressee_id is null then
    raise exception 'not authenticated';
  end if;

  if p_request_id is null then
    raise exception 'request_id is required';
  end if;

  update public.friendship_requests
  set "status" = 'declined', "updated_at" = now()
  where "id" = p_request_id
    and "addressee_id" = v_addressee_id
    and "status" = 'pending';

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'no pending request';
  end if;
end;
$$;

create function public.friendship_request_cancel(
  p_request_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requester_id uuid := (select auth.uid());
  v_updated int;
begin
  if v_requester_id is null then
    raise exception 'not authenticated';
  end if;

  if p_request_id is null then
    raise exception 'request_id is required';
  end if;

  update public.friendship_requests
  set "status" = 'canceled', "updated_at" = now()
  where "id" = p_request_id
    and "requester_id" = v_requester_id
    and "status" = 'pending';

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'no pending request';
  end if;
end;
$$;

create function public.friendship_delete(
  p_friend_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_deleted int;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_friend_id is null then
    raise exception 'friend_id is required';
  end if;

  if v_user_id = p_friend_id then
    raise exception 'cannot unfriend yourself';
  end if;

  delete from public.friendships
  where ("user_id" = v_user_id and "friend_id" = p_friend_id)
     or ("user_id" = p_friend_id and "friend_id" = v_user_id);

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'not friends';
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- Meme mutation RPCs
-- -----------------------------------------------------------------------------

create function public.meme_create(
  p_image_path text,
  p_template_id uuid,
  p_recipient_ids uuid[],
  p_aspect_ratio double precision
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_meme public.memes;
  v_recipient_ids uuid[];
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_image_path is null or length(trim(p_image_path)) = 0 then
    raise exception 'image_path is required';
  end if;

  if p_aspect_ratio is null or p_aspect_ratio <= 0 then
    raise exception 'aspect_ratio must be positive';
  end if;

  if p_recipient_ids is null or array_length(p_recipient_ids, 1) is null then
    raise exception 'recipient_ids is required';
  end if;

  select array_agg(distinct recipient_id)
  into v_recipient_ids
  from (
    select r_id as recipient_id
    from unnest(p_recipient_ids) as r_id
    where r_id is not null
      and r_id <> v_user_id
  ) normalized;

  if v_recipient_ids is null or array_length(v_recipient_ids, 1) is null then
    raise exception 'recipient_ids is required';
  end if;

  if exists (
    select 1
    from unnest(v_recipient_ids) as r_id
    where not exists (
      select 1
      from public.friendships f
      where f."user_id" = v_user_id
        and f."friend_id" = r_id
    )
  ) then
    raise exception 'all recipients must be friends';
  end if;

  insert into public.memes ("user_id", "template_id", "image_path", "aspect_ratio")
  values (v_user_id, p_template_id, p_image_path, p_aspect_ratio)
  returning *
  into v_meme;

  insert into public.meme_recipients ("meme_id", "user_id")
  select v_meme."id", r_id
  from unnest(v_recipient_ids) as r_id
  on conflict do nothing;
end;
$$;

create function public.meme_laugh_toggle(
  p_meme_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if public.is_meme_creator(p_meme_id, v_user_id) then
    raise exception 'cannot laugh own meme';
  end if;

  if not public.can_view_meme(p_meme_id, v_user_id) then
    raise exception 'meme not visible';
  end if;

  if exists (
    select 1
    from public.meme_laughs ml
    where ml."meme_id" = p_meme_id
      and ml."user_id" = v_user_id
  ) then
    delete from public.meme_laughs
    where "meme_id" = p_meme_id
      and "user_id" = v_user_id;

    return false;
  end if;

  insert into public.meme_laughs ("meme_id", "user_id")
  values (p_meme_id, v_user_id)
  on conflict do nothing;

  return true;
end;
$$;

-- -----------------------------------------------------------------------------
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.update_current_user_name(text) is
'Sets public.users.name for the currently authenticated user.';

comment on function public.get_users_profile(uuid) is
'Returns one user details payload for the provided users.id value.';

comment on function public.friendships_list(text, integer, text, uuid) is
'Returns one cursor-paginated page of active friendships for auth.uid().';

comment on function public.friendship_requests_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of pending friendship requests for auth.uid(), including request ids.';

comment on function public.meme_templates_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of active meme templates, optionally filtered by tag search.';

comment on function public.feed_list(integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes created by auth.uid() or received by auth.uid().';

comment on function public.meme_details_get(uuid) is
'Returns one meme details payload for a meme visible to auth.uid(), including creator metadata and current laugh state.';

comment on function public.meme_laughs_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of users who laughed at the specified meme visible to auth.uid().';

comment on function public.friendship_request_create(text) is
'Creates one pending friendship request by addressee friendship code and returns the new request id.';

comment on function public.sync_friendships_from_accepted_request() is
'Creates both directional friendship edges whenever a friendship request becomes accepted.';

comment on function public.friendship_request_accept(uuid) is
'Accepts one incoming pending request by request id and returns the resulting friendship item.';

comment on function public.friendship_request_decline(uuid) is
'Declines one incoming pending request by request id.';

comment on function public.friendship_request_cancel(uuid) is
'Cancels one outgoing pending request by request id.';

comment on function public.friendship_delete(uuid) is
'Deletes both directional friendship edges for auth.uid() and the provided friend id.';

comment on function public.meme_create(text, uuid, uuid[], double precision) is
'Creates one meme for auth.uid(), persists image_path + aspect_ratio, supports optional template_id, validates friend recipients, and inserts recipient edges.';

comment on function public.meme_laugh_toggle(uuid) is
'Toggles one meme laugh for auth.uid() on the provided meme id and returns the resulting liked-state.';

comment on function public.notifications_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of notifications for auth.uid(), optionally filtered by actor name/code.';

comment on function public.notification_mark_read(uuid) is
'Marks one notification as read for auth.uid(); no-op when already read or not owned.';

comment on function public.notifications_mark_all_read() is
'Marks all unread notifications as read for auth.uid() and returns the number of updated rows.';

comment on function public.notifications_unread_count() is
'Returns unread notifications count for auth.uid().';

comment on function public.create_notification_on_friendship_request_sent() is
'Creates a friendship_request_sent notification row after a pending friendship request is inserted.';

comment on function public.create_notification_on_friendship_request_accepted() is
'Creates a friendship_request_accepted notification row when a friendship request becomes accepted.';

comment on function public.create_notifications_on_meme_preview_resolved() is
'Creates meme_received notifications once a meme preview status resolves from pending to ready or failed.';

comment on function public.create_notification_on_meme_laughed() is
'Creates one meme_laughed notification row when a user inserts a meme_laughs edge.';

comment on function public.is_meme_creator(uuid, uuid) is
'Returns whether the given user id created the given meme id.';

comment on function public.is_meme_recipient(uuid, uuid) is
'Returns whether the given user id is a recipient of the given meme id.';

comment on function public.can_view_meme(uuid, uuid) is
'Returns whether the given user id can view the given meme as creator or recipient.';

comment on function public.push_token_upsert(text, text, public.push_platform, text, text) is
'Upserts one active push token for auth.uid() + installation_id and stores locale metadata.';

comment on function public.push_token_deactivate_current_device(text, public.push_token_deactivation_reason) is
'Soft-deactivates all active tokens for auth.uid() on the provided installation_id.';

comment on function public.push_tokens_cleanup_inactive(interval) is
'Deletes inactive push-token rows older than the configured retention interval and returns the deleted count.';

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.update_current_user_name(text) from public;
revoke all on function public.get_users_profile(uuid) from public;
revoke all on function public.friendships_list(text, integer, text, uuid) from public;
revoke all on function public.friendship_requests_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.meme_templates_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.feed_list(integer, timestamptz, uuid) from public;
revoke all on function public.meme_details_get(uuid) from public;
revoke all on function public.meme_laughs_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.friendship_request_create(text) from public;
revoke all on function public.friendship_request_accept(uuid) from public;
revoke all on function public.friendship_request_decline(uuid) from public;
revoke all on function public.friendship_request_cancel(uuid) from public;
revoke all on function public.friendship_delete(uuid) from public;
revoke all on function public.meme_create(text, uuid, uuid[], double precision) from public;
revoke all on function public.meme_laugh_toggle(uuid) from public;
revoke all on function public.notifications_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.notification_mark_read(uuid) from public;
revoke all on function public.notifications_mark_all_read() from public;
revoke all on function public.notifications_unread_count() from public;
revoke all on function public.is_meme_creator(uuid, uuid) from public;
revoke all on function public.is_meme_recipient(uuid, uuid) from public;
revoke all on function public.can_view_meme(uuid, uuid) from public;
revoke all on function public.push_token_upsert(text, text, public.push_platform, text, text) from public;
revoke all on function public.push_token_deactivate_current_device(text, public.push_token_deactivation_reason) from public;
revoke all on function public.push_tokens_cleanup_inactive(interval) from public;
revoke all on function public.get_required_vault_secret(text) from public;
revoke all on function public.upsert_vault_secret(text, text, text) from public;
revoke all on function public.invoke_internal_edge_function(text, jsonb, integer) from public;
revoke all on function public.enqueue_generate_meme_push_preview() from public;
revoke all on function public.enqueue_send_notification_push() from public;
grant execute on function public.update_current_user_name(text) to authenticated;
grant execute on function public.get_users_profile(uuid) to authenticated;
grant execute on function public.friendships_list(text, integer, text, uuid) to authenticated;
grant execute on function public.friendship_requests_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_templates_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.feed_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_details_get(uuid) to authenticated;
grant execute on function public.meme_laughs_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.friendship_request_create(text) to authenticated;
grant execute on function public.friendship_request_accept(uuid) to authenticated;
grant execute on function public.friendship_request_decline(uuid) to authenticated;
grant execute on function public.friendship_request_cancel(uuid) to authenticated;
grant execute on function public.friendship_delete(uuid) to authenticated;
grant execute on function public.meme_create(text, uuid, uuid[], double precision) to authenticated;
grant execute on function public.meme_laugh_toggle(uuid) to authenticated;
grant execute on function public.notifications_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.notification_mark_read(uuid) to authenticated;
grant execute on function public.notifications_mark_all_read() to authenticated;
grant execute on function public.notifications_unread_count() to authenticated;
grant execute on function public.is_meme_creator(uuid, uuid) to authenticated;
grant execute on function public.is_meme_recipient(uuid, uuid) to authenticated;
grant execute on function public.can_view_meme(uuid, uuid) to authenticated;
grant execute on function public.push_token_upsert(text, text, public.push_platform, text, text) to authenticated;
grant execute on function public.push_token_deactivate_current_device(text, public.push_token_deactivation_reason) to authenticated;

-- -----------------------------------------------------------------------------
-- Realtime publication setup
-- -----------------------------------------------------------------------------

do $$
begin
  if exists (
    select 1
    from pg_catalog.pg_publication p
    where p.pubname = 'supabase_realtime'
  ) then
    begin
      execute 'alter publication supabase_realtime add table public.notifications';
    exception
      when duplicate_object then
        null;
    end;
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- Cron jobs
-- -----------------------------------------------------------------------------

create extension if not exists pg_cron with schema extensions;

select cron.schedule(
  'push_tokens_cleanup_inactive_daily',
  '15 3 * * *',
  $cron$
    select public.invoke_internal_edge_function('cron-push-tokens-cleanup');
  $cron$
);

select cron.schedule(
  'memes_storage_cleanup_orphans_daily',
  '20 3 * * *',
  $cron$
    select public.invoke_internal_edge_function('cron-memes-storage-orphans-cleanup');
  $cron$
);

select cron.schedule(
  'memes_push_storage_cleanup_orphans_daily',
  '35 3 * * *',
  $cron$
    select public.invoke_internal_edge_function('cron-memes-push-storage-orphans-cleanup');
  $cron$
);

-- -----------------------------------------------------------------------------
-- Storage buckets and policies
-- -----------------------------------------------------------------------------

insert into storage.buckets ("id", "name", "public")
values ('meme_templates', 'meme_templates', false)
on conflict do nothing;

create policy "storage.objects:meme_templates:select:authenticated"
on storage.objects
for select
to authenticated
using (
  "bucket_id" = 'meme_templates'
  and exists (
    select 1
    from public.meme_templates t
    where t."image_path" = storage.objects."name"
      and t."is_active" = true
  )
);

insert into storage.buckets ("id", "name", "public")
values ('memes', 'memes', false)
on conflict do nothing;

insert into storage.buckets ("id", "name", "public")
values ('memes_push', 'memes_push', false)
on conflict do nothing;

create policy "storage.objects:memes:insert:authenticated"
on storage.objects
for insert
to authenticated
with check (
  "bucket_id" = 'memes'
  and (storage.foldername("name"))[1] = ((select auth.uid()))::text
);

create policy "storage.objects:memes:select:owner_or_recipient:authenticated"
on storage.objects
for select
to authenticated
using (
  "bucket_id" = 'memes'
  and exists (
    select 1
    from public.memes m
    where m."image_path" = storage.objects."name"
      and public.can_view_meme(m."id", (select auth.uid()))
  )
);

create policy "storage.objects:memes_push:select:owner_or_recip:authenticated"
on storage.objects
for select
to authenticated
using (
  "bucket_id" = 'memes_push'
  and exists (
    select 1
    from public.memes m
    where m."push_image_path" = storage.objects."name"
      and public.can_view_meme(m."id", (select auth.uid()))
  )
);
