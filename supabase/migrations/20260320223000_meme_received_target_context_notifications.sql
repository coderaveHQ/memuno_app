-- -----------------------------------------------------------------------------
-- Notification constraints
-- -----------------------------------------------------------------------------

alter table public.notifications
  drop constraint if exists ck_notifications__data_shape;

alter table public.notifications
  add constraint ck_notifications__data_shape
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
      when 'group_invitation_sent' then
        jsonb_typeof("data") = 'object'
        and jsonb_typeof("data"->'actor_id') = 'string'
        and jsonb_typeof("data"->'actor_name') = 'string'
        and jsonb_typeof("data"->'actor_friendship_code') = 'string'
        and jsonb_typeof("data"->'invitation_id') = 'string'
        and jsonb_typeof("data"->'group_id') = 'string'
        and jsonb_typeof("data"->'group_name') = 'string'
        and ("data"->>'actor_friendship_code') ~ '^[0-9]{8}$'
        and length(trim("data"->>'group_name')) > 0
        and "data" ? 'route_tab'
        and ("data"->>'route_tab') = 'invitations'
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
        and (
          not ("data" ? 'group_id')
          or ("data"->'group_id') = 'null'::jsonb
          or jsonb_typeof("data"->'group_id') = 'string'
        )
        and (
          not ("data" ? 'group_name')
          or ("data"->'group_name') = 'null'::jsonb
          or (
            jsonb_typeof("data"->'group_name') = 'string'
            and length(trim("data"->>'group_name')) > 0
          )
        )
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
  );

-- -----------------------------------------------------------------------------
-- Notification indexes
-- -----------------------------------------------------------------------------

drop index if exists public.notifications_meme_received_recipient_meme_id_uidx;

create unique index notifications_meme_received_recipient_meme_id_uidx
on public.notifications (
  "recipient_id",
  ("data"->>'meme_id'),
  (coalesce("data"->>'group_id', '__direct__'))
)
where "type" = 'meme_received';

-- -----------------------------------------------------------------------------
-- Meme notification fan-out by recipient target context
-- -----------------------------------------------------------------------------

create or replace function public.create_notifications_on_meme_preview_resolved()
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
    recipients."recipient_id",
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
      'group_id',
      recipients."group_id",
      'group_name',
      recipients."group_name",
      'route_tab',
      to_jsonb(null::text)
    )
  from (
    select
      mr."user_id" as "recipient_id",
      null::uuid as "group_id",
      null::text as "group_name"
    from public.meme_recipients mr
    where mr."meme_id" = new."id"
      and mr."user_id" is not null
    union all
    select
      gu."user_id" as "recipient_id",
      g."id" as "group_id",
      g."name" as "group_name"
    from public.meme_recipients mr
    join public.groups g on g."id" = mr."group_id"
    join public.group_users gu on gu."group_id" = mr."group_id"
    where mr."meme_id" = new."id"
      and mr."group_id" is not null
  ) recipients
  where recipients."recipient_id" <> new."user_id"
  on conflict do nothing;

  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Push templates for meme target context wording
-- -----------------------------------------------------------------------------

insert into public.notification_push_templates (
  "notification_type",
  "language_code",
  "country_code",
  "title",
  "message"
)
values
  (
    'meme_received',
    'en',
    null,
    'New meme received',
    '{sender_name} sent a meme to {recipient_target_name}.'
  ),
  (
    'meme_received',
    'en',
    'US',
    'New meme received',
    '{sender_name} sent a meme to {recipient_target_name}.'
  ),
  (
    'meme_received',
    'de',
    null,
    'Neues Meme erhalten',
    '{sender_name} hat ein Meme an {recipient_target_name} gesendet.'
  ),
  (
    'meme_received',
    'de',
    'DE',
    'Neues Meme erhalten',
    '{sender_name} hat ein Meme an {recipient_target_name} gesendet.'
  )
on conflict ("notification_type", "language_code", "country_code")
do update
set
  "title" = excluded."title",
  "message" = excluded."message",
  "updated_at" = now();
