-- -----------------------------------------------------------------------------
-- Groups domain types
-- -----------------------------------------------------------------------------

create type public.group_user_type
  as enum ('creator', 'admin', 'member');

create type public.group_invitation_status
  as enum ('pending', 'accepted', 'rejected', 'canceled');

create type public.group_item as (
  "id" uuid,
  "name" text,
  "member_count" integer,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.group_invitation_item as (
  "id" uuid,
  "status" public.group_invitation_status,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "group" public.group_item,
  "inviter" public.user_item
);

create type public.group_details as (
  "id" uuid,
  "name" text,
  "member_count" integer,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "my_user_type" public.group_user_type,
  "is_member" boolean,
  "has_pending_invitation" boolean,
  "can_manage_members" boolean,
  "can_add_members" boolean,
  "can_delete_group" boolean
);

create type public.group_member_item as (
  "type" public.group_user_type,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "user" public.user_item
);

create type public.group_pending_invitation_item as (
  "id" uuid,
  "status" public.group_invitation_status,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "invitee" public.user_item,
  "inviter" public.user_item
);

create type public.meme_recipient_target_type
  as enum ('user', 'group');

create type public.meme_recipient_target_item as (
  "type" public.meme_recipient_target_type,
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "member_count" integer,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

-- -----------------------------------------------------------------------------
-- Groups tables
-- -----------------------------------------------------------------------------

create table public.groups (
  "id" uuid not null default gen_random_uuid(),
  "name" text not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_groups primary key ("id"),
  constraint ck_groups__name_length
    check (length(trim("name")) between 1 and 64)
);

create table public.group_users (
  "group_id" uuid not null,
  "user_id" uuid not null,
  "type" public.group_user_type not null default 'member',
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_group_users primary key ("group_id", "user_id"),
  constraint fk_group_users__group_id__groups__id
    foreign key ("group_id") references public.groups ("id")
    on update cascade on delete cascade,
  constraint fk_group_users__user_id__auth_users__id
    foreign key ("user_id") references auth.users ("id")
    on update cascade on delete cascade
);

create table public.group_invitations (
  "id" uuid not null default gen_random_uuid(),
  "group_id" uuid not null,
  "inviter_id" uuid not null,
  "invitee_id" uuid not null,
  "status" public.group_invitation_status not null default 'pending',
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  constraint pk_group_invitations primary key ("id"),
  constraint fk_group_invitations__group_id__groups__id
    foreign key ("group_id") references public.groups ("id")
    on update cascade on delete cascade,
  constraint fk_group_invitations__inviter_id__auth_users__id
    foreign key ("inviter_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint fk_group_invitations__invitee_id__auth_users__id
    foreign key ("invitee_id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_group_invitations__neq_user_ids
    check ("inviter_id" <> "invitee_id")
);

-- -----------------------------------------------------------------------------
-- Meme recipients table reshaping (user or group target)
-- -----------------------------------------------------------------------------

alter table public.meme_recipients
  drop constraint if exists pk_meme_recipients;

alter table public.meme_recipients
  add column if not exists "id" uuid not null default gen_random_uuid(),
  add column if not exists "group_id" uuid;

alter table public.meme_recipients
  alter column "user_id" drop not null;

alter table public.meme_recipients
  add constraint pk_meme_recipients primary key ("id");

alter table public.meme_recipients
  add constraint fk_meme_recipients__group_id__groups__id
    foreign key ("group_id") references public.groups ("id")
    on update cascade on delete cascade;

alter table public.meme_recipients
  add constraint ck_meme_recipients__exactly_one_target
    check (num_nonnulls("user_id", "group_id") = 1);

drop index if exists meme_recipients_user_id_meme_id_idx;

create unique index meme_recipients_meme_id_user_id_uidx
on public.meme_recipients ("meme_id", "user_id")
where "user_id" is not null;

create unique index meme_recipients_meme_id_group_id_uidx
on public.meme_recipients ("meme_id", "group_id")
where "group_id" is not null;

create index meme_recipients_user_id_meme_id_idx
on public.meme_recipients ("user_id", "meme_id")
where "user_id" is not null;

create index meme_recipients_group_id_meme_id_idx
on public.meme_recipients ("group_id", "meme_id")
where "group_id" is not null;

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
-- Groups indexes
-- -----------------------------------------------------------------------------

create index groups_created_at_id_idx
on public.groups ("created_at" desc, "id" desc);

create index group_users_user_id_created_at_group_id_idx
on public.group_users ("user_id", "created_at" desc, "group_id" desc);

create index group_users_group_id_created_at_user_id_idx
on public.group_users ("group_id", "created_at" desc, "user_id" desc);

create unique index group_users_one_creator_per_group_uidx
on public.group_users ("group_id")
where "type" = 'creator';

create unique index group_invitations_one_pending_per_group_invitee_uidx
on public.group_invitations ("group_id", "invitee_id")
where "status" = 'pending';

create index group_invitations_invitee_pending_idx
on public.group_invitations ("invitee_id", "created_at" desc, "id" desc)
where "status" = 'pending';

create index group_invitations_group_pending_idx
on public.group_invitations ("group_id", "created_at" desc, "id" desc)
where "status" = 'pending';

-- -----------------------------------------------------------------------------
-- Groups helper and trigger functions
-- -----------------------------------------------------------------------------

create function public.get_group_item(
  p_group_id uuid
)
returns public.group_item
language sql
stable
security definer
set search_path = public
as $$
  select row(
    g."id",
    g."name",
    (
      select count(*)::integer
      from public.group_users gu_count
      where gu_count."group_id" = g."id"
    ),
    g."created_at",
    g."updated_at"
  )::public.group_item
  from public.groups g
  where g."id" = p_group_id
  limit 1;
$$;

create function public.can_access_group(
  p_group_id uuid,
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
    from public.group_users gu
    where gu."group_id" = p_group_id
      and gu."user_id" = p_user_id
  )
  or exists (
    select 1
    from public.group_invitations gi
    where gi."group_id" = p_group_id
      and gi."invitee_id" = p_user_id
      and gi."status" = 'pending'
  );
$$;

create function public.sync_group_users_from_accepted_invitation()
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

  insert into public.group_users ("group_id", "user_id", "type")
  values (new."group_id", new."invitee_id", 'member')
  on conflict ("group_id", "user_id") do nothing;

  return new;
end;
$$;

create function public.cleanup_group_after_user_removed()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  delete from public.meme_recipients mr
  using public.memes m
  where mr."meme_id" = m."id"
    and mr."group_id" = old."group_id"
    and m."user_id" = old."user_id";

  if not exists (
    select 1
    from public.group_users gu
    where gu."group_id" = old."group_id"
  ) then
    update public.group_invitations
    set
      "status" = 'canceled',
      "updated_at" = now()
    where "group_id" = old."group_id"
      and "status" = 'pending';

    delete from public.groups
    where "id" = old."group_id";

    return old;
  end if;

  return old;
end;
$$;

create function public.cleanup_meme_after_recipient_removed()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if exists (
    select 1
    from public.meme_recipients mr
    where mr."meme_id" = old."meme_id"
  ) then
    return old;
  end if;

  delete from public.memes
  where "id" = old."meme_id";

  return old;
end;
$$;

create function public.create_notification_on_group_invitation_sent()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_actor public.users;
  v_group public.groups;
begin
  if new."status" <> 'pending' then
    return new;
  end if;

  select *
  into v_actor
  from public.users u
  where u."id" = new."inviter_id";

  if v_actor."id" is null then
    raise exception 'group invitation actor not found';
  end if;

  select *
  into v_group
  from public.groups g
  where g."id" = new."group_id";

  if v_group."id" is null then
    raise exception 'group not found for invitation notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    new."invitee_id",
    'group_invitation_sent',
    jsonb_build_object(
      'actor_id',
      v_actor."id",
      'actor_name',
      v_actor."name",
      'actor_friendship_code',
      v_actor."friendship_code",
      'invitation_id',
      new."id",
      'group_id',
      new."group_id",
      'group_name',
      v_group."name",
      'route_tab',
      'invitations'
    )
  );

  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Timestamp and domain triggers
-- -----------------------------------------------------------------------------

create trigger trg_groups__touch_updated_at
before update on public.groups
for each row
execute function public.touch_updated_at();

create trigger trg_group_users__touch_updated_at
before update on public.group_users
for each row
execute function public.touch_updated_at();

create trigger trg_group_invitations__touch_updated_at
before update on public.group_invitations
for each row
execute function public.touch_updated_at();

create trigger trg_group_invitations__sync_group_users_on_accepted
after insert or update of "status" on public.group_invitations
for each row
execute function public.sync_group_users_from_accepted_invitation();

create trigger trg_group_users__cleanup_after_delete
after delete on public.group_users
for each row
execute function public.cleanup_group_after_user_removed();

create trigger trg_meme_recipients__cleanup_meme_after_delete
after delete on public.meme_recipients
for each row
execute function public.cleanup_meme_after_recipient_removed();

create trigger trg_group_invitations__create_notification_on_insert
after insert on public.group_invitations
for each row
execute function public.create_notification_on_group_invitation_sent();

-- -----------------------------------------------------------------------------
-- Groups and recipient-target list RPCs
-- -----------------------------------------------------------------------------

create function public.groups_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
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
      g."id",
      g."name",
      g."created_at",
      g."updated_at",
      (
        select count(*)::integer
        from public.group_users gu_count
        where gu_count."group_id" = g."id"
      ) as "member_count"
    from public.groups g
    where exists (
      select 1
      from public.group_users me
      where me."group_id" = g."id"
        and me."user_id" = (select "user_id" from params)
    )
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("name") like '%' || lower((select "search_term" from params)) || '%'
  ),
  ordered as (
    select
      row(
        "id",
        "name",
        "member_count",
        "created_at",
        "updated_at"
      )::public.group_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.group_invitations_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
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
      gi."id",
      gi."status",
      gi."created_at",
      gi."updated_at",
      g."id" as "group_id",
      g."name" as "group_name",
      g."created_at" as "group_created_at",
      g."updated_at" as "group_updated_at",
      (
        select count(*)::integer
        from public.group_users gu_count
        where gu_count."group_id" = g."id"
      ) as "group_member_count",
      inviter."id" as "inviter_id",
      inviter."name" as "inviter_name",
      inviter."friendship_code" as "inviter_friendship_code",
      inviter."created_at" as "inviter_created_at",
      inviter."updated_at" as "inviter_updated_at"
    from public.group_invitations gi
    join public.groups g on g."id" = gi."group_id"
    join public.users inviter on inviter."id" = gi."inviter_id"
    where gi."invitee_id" = (select "user_id" from params)
      and gi."status" = 'pending'
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("group_name") like '%' || lower((select "search_term" from params)) || '%'
      or lower("inviter_name") like '%' || lower((select "search_term" from params)) || '%'
  ),
  ordered as (
    select
      row(
        "id",
        "status",
        "created_at",
        "updated_at",
        row(
          "group_id",
          "group_name",
          "group_member_count",
          "group_created_at",
          "group_updated_at"
        )::public.group_item,
        row(
          "inviter_id",
          "inviter_name",
          "inviter_friendship_code",
          "inviter_created_at",
          "inviter_updated_at"
        )::public.user_item
      )::public.group_invitation_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.meme_recipient_targets_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "user_id",
      nullif(trim(p_search), '') as "search_term"
  ),
  user_targets as (
    select
      'user'::public.meme_recipient_target_type as "type",
      u."id",
      u."name",
      u."friendship_code",
      null::integer as "member_count",
      f."created_at",
      f."updated_at"
    from public.friendships f
    join public.users u on u."id" = f."friend_id"
    where f."user_id" = (select "user_id" from params)
  ),
  group_targets as (
    select
      'group'::public.meme_recipient_target_type as "type",
      g."id",
      g."name",
      null::text as "friendship_code",
      (
        select count(*)::integer
        from public.group_users gu_count
        where gu_count."group_id" = g."id"
      ) as "member_count",
      gu_me."created_at",
      g."updated_at"
    from public.group_users gu_me
    join public.groups g on g."id" = gu_me."group_id"
    where gu_me."user_id" = (select "user_id" from params)
  ),
  base as (
    select * from user_targets
    union all
    select * from group_targets
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("name") like '%' || lower((select "search_term" from params)) || '%'
      or coalesce("friendship_code", '') like '%' || (select "search_term" from params) || '%'
  ),
  ordered as (
    select
      row(
        "type",
        "id",
        "name",
        "friendship_code",
        "member_count",
        "created_at",
        "updated_at"
      )::public.meme_recipient_target_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Groups mutation RPCs
-- -----------------------------------------------------------------------------

create function public.group_create(
  p_name text,
  p_invitee_ids uuid[] default '{}'::uuid[]
)
returns public.group_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_group_name text;
  v_group public.groups;
  v_invitee_ids uuid[];
  v_result public.group_item;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_group_name := nullif(trim(p_name), '');
  if v_group_name is null then
    raise exception 'group name is required';
  end if;

  if length(v_group_name) > 64 then
    raise exception 'group name must be at most 64 characters';
  end if;

  select coalesce(array_agg(distinct invitee_id), '{}'::uuid[])
  into v_invitee_ids
  from (
    select invitee_id
    from unnest(coalesce(p_invitee_ids, '{}'::uuid[])) as invitee_id
    where invitee_id is not null
      and invitee_id <> v_user_id
  ) normalized;

  if exists (
    select 1
    from unnest(v_invitee_ids) as invitee_id
    where not exists (
      select 1
      from public.friendships f
      where f."user_id" = v_user_id
        and f."friend_id" = invitee_id
    )
  ) then
    raise exception 'all invitees must be friends';
  end if;

  insert into public.groups ("name")
  values (v_group_name)
  returning *
  into v_group;

  insert into public.group_users ("group_id", "user_id", "type")
  values (v_group."id", v_user_id, 'creator');

  insert into public.group_invitations ("group_id", "inviter_id", "invitee_id")
  select
    v_group."id",
    v_user_id,
    invitee_id
  from unnest(v_invitee_ids) as invitee_id
  on conflict ("group_id", "invitee_id") where "status" = 'pending'
  do nothing;

  v_result := public.get_group_item(v_group."id");

  if v_result is null then
    raise exception 'failed to load created group';
  end if;

  return v_result;
end;
$$;

create function public.group_invitation_accept(
  p_invitation_id uuid
)
returns public.group_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_group_id uuid;
  v_result public.group_item;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_invitation_id is null then
    raise exception 'invitation_id is required';
  end if;

  update public.group_invitations gi
  set
    "status" = 'accepted',
    "updated_at" = now()
  where gi."id" = p_invitation_id
    and gi."invitee_id" = v_user_id
    and gi."status" = 'pending'
  returning gi."group_id"
  into v_group_id;

  if v_group_id is null then
    raise exception 'no pending invitation';
  end if;

  insert into public.group_users ("group_id", "user_id", "type")
  values (v_group_id, v_user_id, 'member')
  on conflict ("group_id", "user_id") do nothing;

  v_result := public.get_group_item(v_group_id);

  if v_result is null then
    raise exception 'group not found';
  end if;

  return v_result;
end;
$$;

create function public.group_invitation_reject(
  p_invitation_id uuid
)
returns void
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

  if p_invitation_id is null then
    raise exception 'invitation_id is required';
  end if;

  update public.group_invitations
  set
    "status" = 'rejected',
    "updated_at" = now()
  where "id" = p_invitation_id
    and "invitee_id" = v_user_id
    and "status" = 'pending';

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'no pending invitation';
  end if;
end;
$$;

create function public.group_invitation_cancel(
  p_invitation_id uuid
)
returns void
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

  if p_invitation_id is null then
    raise exception 'invitation_id is required';
  end if;

  update public.group_invitations gi
  set
    "status" = 'canceled',
    "updated_at" = now()
  where gi."id" = p_invitation_id
    and gi."status" = 'pending'
    and (
      gi."inviter_id" = v_user_id
      or exists (
        select 1
        from public.group_users gu
        where gu."group_id" = gi."group_id"
          and gu."user_id" = v_user_id
          and gu."type" in ('creator', 'admin')
      )
    );

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'no pending invitation';
  end if;
end;
$$;

create function public.group_leave(
  p_group_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_member_count integer;
  v_remaining_admin_count integer;
  v_deleted integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_user_id
  limit 1;

  if v_actor_type is null then
    raise exception 'not a group member';
  end if;

  select count(*)::integer
  into v_member_count
  from public.group_users gu
  where gu."group_id" = p_group_id;

  if v_member_count <= 1 then
    raise exception 'cannot leave group with one member';
  end if;

  if v_actor_type in ('creator', 'admin') then
    select count(*)::integer
    into v_remaining_admin_count
    from public.group_users gu
    where gu."group_id" = p_group_id
      and gu."user_id" <> v_user_id
      and gu."type" = 'admin';

    if v_remaining_admin_count = 0 then
      raise exception 'cannot leave group without another admin';
    end if;
  end if;

  delete from public.group_users
  where "group_id" = p_group_id
    and "user_id" = v_user_id;

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'not a group member';
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- Meme mutation RPC update (user + group recipients)
-- -----------------------------------------------------------------------------

drop function if exists public.meme_create(text, uuid, uuid[], double precision);

create function public.meme_create(
  p_image_path text,
  p_template_id uuid,
  p_recipient_ids uuid[],
  p_group_ids uuid[] default '{}'::uuid[],
  p_aspect_ratio double precision default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_meme public.memes;
  v_direct_recipient_ids uuid[];
  v_group_ids uuid[];
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_image_path is null or length(trim(p_image_path)) = 0 then
    raise exception 'image_path is required';
  end if;

  if p_template_id is null then
    raise exception 'template_id is required';
  end if;

  if p_aspect_ratio is null or p_aspect_ratio <= 0 then
    raise exception 'aspect_ratio must be positive';
  end if;

  select coalesce(array_agg(distinct recipient_id), '{}'::uuid[])
  into v_direct_recipient_ids
  from (
    select recipient_id
    from unnest(coalesce(p_recipient_ids, '{}'::uuid[])) as recipient_id
    where recipient_id is not null
      and recipient_id <> v_user_id
  ) normalized;

  select coalesce(array_agg(distinct group_id), '{}'::uuid[])
  into v_group_ids
  from (
    select group_id
    from unnest(coalesce(p_group_ids, '{}'::uuid[])) as group_id
    where group_id is not null
  ) normalized;

  if array_length(v_direct_recipient_ids, 1) is null
     and array_length(v_group_ids, 1) is null then
    raise exception 'recipient_ids is required';
  end if;

  if exists (
    select 1
    from unnest(v_direct_recipient_ids) as recipient_id
    where not exists (
      select 1
      from public.friendships f
      where f."user_id" = v_user_id
        and f."friend_id" = recipient_id
    )
  ) then
    raise exception 'all direct recipients must be friends';
  end if;

  if exists (
    select 1
    from unnest(v_group_ids) as group_id
    where not exists (
      select 1
      from public.group_users gu
      where gu."group_id" = group_id
        and gu."user_id" = v_user_id
    )
  ) then
    raise exception 'all groups must include the sender';
  end if;

  insert into public.memes ("user_id", "template_id", "image_path", "aspect_ratio")
  values (v_user_id, p_template_id, p_image_path, p_aspect_ratio)
  returning *
  into v_meme;

  insert into public.meme_recipients ("meme_id", "user_id")
  select v_meme."id", recipient_id
  from unnest(v_direct_recipient_ids) as recipient_id
  on conflict do nothing;

  insert into public.meme_recipients ("meme_id", "group_id")
  select v_meme."id", group_id
  from unnest(v_group_ids) as group_id
  on conflict do nothing;
end;
$$;

-- -----------------------------------------------------------------------------
-- Group details read and mutation RPCs
-- -----------------------------------------------------------------------------

create function public.group_details_get(
  p_group_id uuid
)
returns public.group_details
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_group public.groups;
  v_my_user_type public.group_user_type;
  v_is_member boolean := false;
  v_has_pending_invitation boolean := false;
  v_member_count integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  select *
  into v_group
  from public.groups g
  where g."id" = p_group_id
  limit 1;

  if v_group."id" is null then
    raise exception 'group not found';
  end if;

  select gu."type"
  into v_my_user_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_user_id
  limit 1;

  v_is_member := v_my_user_type is not null;

  select exists (
    select 1
    from public.group_invitations gi
    where gi."group_id" = p_group_id
      and gi."invitee_id" = v_user_id
      and gi."status" = 'pending'
  )
  into v_has_pending_invitation;

  if not v_is_member and not v_has_pending_invitation then
    raise exception 'group not visible';
  end if;

  select count(*)::integer
  into v_member_count
  from public.group_users gu_count
  where gu_count."group_id" = p_group_id;

  return row(
    v_group."id",
    v_group."name",
    v_member_count,
    v_group."created_at",
    v_group."updated_at",
    v_my_user_type,
    v_is_member,
    v_has_pending_invitation,
    coalesce(v_my_user_type in ('creator', 'admin'), false),
    coalesce(v_my_user_type in ('creator', 'admin'), false),
    coalesce(v_my_user_type in ('creator', 'admin'), false)
  )::public.group_details;
end;
$$;

create function public.group_details_memes_all_list(
  p_group_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "user_id"
  ),
  access_check as (
    select public.can_access_group(
      p_group_id,
      (select "user_id" from params)
    ) as "allowed"
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
    where (select "allowed" from access_check)
      and exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."group_id" = p_group_id
      )
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.group_details_memes_sent_by_me_list(
  p_group_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "user_id"
  ),
  access_check as (
    select public.can_access_group(
      p_group_id,
      (select "user_id" from params)
    ) as "allowed"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      false as "is_laughed",
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
    where (select "allowed" from access_check)
      and m."user_id" = (select "user_id" from params)
      and exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."group_id" = p_group_id
      )
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.group_details_members_list(
  p_group_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "user_id"
  ),
  access_check as (
    select public.can_access_group(
      p_group_id,
      (select "user_id" from params)
    ) as "allowed"
  ),
  base as (
    select
      gu."type" as "member_type",
      gu."created_at" as "member_created_at",
      gu."updated_at" as "member_updated_at",
      u."id" as "user_id",
      u."name" as "user_name",
      u."friendship_code" as "user_friendship_code",
      u."created_at" as "user_created_at",
      u."updated_at" as "user_updated_at"
    from public.group_users gu
    join public.users u on u."id" = gu."user_id"
    where (select "allowed" from access_check)
      and gu."group_id" = p_group_id
  ),
  ordered as (
    select
      row(
        "member_type",
        "member_created_at",
        "member_updated_at",
        row(
          "user_id",
          "user_name",
          "user_friendship_code",
          "user_created_at",
          "user_updated_at"
        )::public.user_item
      )::public.group_member_item as "item",
      "member_created_at" as "sort_created_at",
      "user_id" as "sort_id"
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.group_details_pending_invitations_list(
  p_group_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "user_id"
  ),
  access_check as (
    select public.can_access_group(
      p_group_id,
      (select "user_id" from params)
    ) as "allowed"
  ),
  base as (
    select
      gi."id",
      gi."status",
      gi."created_at",
      gi."updated_at",
      invitee."id" as "invitee_id",
      invitee."name" as "invitee_name",
      invitee."friendship_code" as "invitee_friendship_code",
      invitee."created_at" as "invitee_created_at",
      invitee."updated_at" as "invitee_updated_at",
      inviter."id" as "inviter_id",
      inviter."name" as "inviter_name",
      inviter."friendship_code" as "inviter_friendship_code",
      inviter."created_at" as "inviter_created_at",
      inviter."updated_at" as "inviter_updated_at"
    from public.group_invitations gi
    join public.users invitee on invitee."id" = gi."invitee_id"
    join public.users inviter on inviter."id" = gi."inviter_id"
    where (select "allowed" from access_check)
      and gi."group_id" = p_group_id
      and gi."status" = 'pending'
  ),
  ordered as (
    select
      row(
        "id",
        "status",
        "created_at",
        "updated_at",
        row(
          "invitee_id",
          "invitee_name",
          "invitee_friendship_code",
          "invitee_created_at",
          "invitee_updated_at"
        )::public.user_item,
        row(
          "inviter_id",
          "inviter_name",
          "inviter_friendship_code",
          "inviter_created_at",
          "inviter_updated_at"
        )::public.user_item
      )::public.group_pending_invitation_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.group_invitable_friends_list(
  p_group_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_user_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  return (
    with base as (
      select
        f."created_at" as "friendship_created_at",
        u."id" as "user_id",
        u."name" as "user_name",
        u."friendship_code" as "user_friendship_code",
        u."created_at" as "user_created_at",
        u."updated_at" as "user_updated_at"
      from public.friendships f
      join public.users u on u."id" = f."friend_id"
      where f."user_id" = v_user_id
        and not exists (
          select 1
          from public.group_users gu_existing
          where gu_existing."group_id" = p_group_id
            and gu_existing."user_id" = f."friend_id"
        )
        and not exists (
          select 1
          from public.group_invitations gi_pending
          where gi_pending."group_id" = p_group_id
            and gi_pending."invitee_id" = f."friend_id"
            and gi_pending."status" = 'pending'
        )
    ),
    ordered as (
      select
        row(
          "user_id",
          "user_name",
          "user_friendship_code",
          "user_created_at",
          "user_updated_at"
        )::public.user_item as "item",
        "friendship_created_at" as "sort_created_at",
        "user_id" as "sort_id"
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
    select row(
      coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
      (select "next_created_at" from next_cursor),
      (select "next_id" from next_cursor)
    )::public.list_page
    from paged
  );
end;
$$;

create function public.group_members_invite(
  p_group_id uuid,
  p_invitee_ids uuid[] default '{}'::uuid[]
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_invitee_ids uuid[];
begin
  if v_actor_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_actor_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  select coalesce(array_agg(distinct invitee_id), '{}'::uuid[])
  into v_invitee_ids
  from (
    select invitee_id
    from unnest(coalesce(p_invitee_ids, '{}'::uuid[])) as invitee_id
    where invitee_id is not null
      and invitee_id <> v_actor_id
  ) normalized;

  if array_length(v_invitee_ids, 1) is null then
    return;
  end if;

  if exists (
    select 1
    from unnest(v_invitee_ids) as invitee_id
    where not exists (
      select 1
      from public.friendships f
      where f."user_id" = v_actor_id
        and f."friend_id" = invitee_id
    )
  ) then
    raise exception 'all invitees must be friends';
  end if;

  if exists (
    select 1
    from unnest(v_invitee_ids) as invitee_id
    where exists (
      select 1
      from public.group_users gu
      where gu."group_id" = p_group_id
        and gu."user_id" = invitee_id
    )
  ) then
    raise exception 'cannot invite existing members';
  end if;

  insert into public.group_invitations ("group_id", "inviter_id", "invitee_id")
  select
    p_group_id,
    v_actor_id,
    invitee_id
  from unnest(v_invitee_ids) as invitee_id
  on conflict ("group_id", "invitee_id") where "status" = 'pending'
  do nothing;
end;
$$;

create function public.group_member_role_update(
  p_group_id uuid,
  p_user_id uuid,
  p_type public.group_user_type
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_target_type public.group_user_type;
  v_updated integer;
begin
  if v_actor_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  if p_user_id is null then
    raise exception 'user_id is required';
  end if;

  if p_type is null then
    raise exception 'type is required';
  end if;

  if p_type not in ('admin', 'member') then
    raise exception 'invalid target role';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_actor_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  select gu."type"
  into v_target_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = p_user_id
  limit 1;

  if v_target_type is null then
    raise exception 'member not found';
  end if;

  if v_target_type = 'creator' then
    raise exception 'cannot change creator role';
  end if;

  if v_target_type = p_type then
    return;
  end if;

  update public.group_users
  set
    "type" = p_type,
    "updated_at" = now()
  where "group_id" = p_group_id
    and "user_id" = p_user_id
    and "type" <> p_type;

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'member not found';
  end if;
end;
$$;

create function public.group_name_update(
  p_group_id uuid,
  p_name text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_group_name text;
  v_updated integer;
begin
  if v_actor_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  v_group_name := nullif(trim(p_name), '');
  if v_group_name is null then
    raise exception 'group name is required';
  end if;

  if length(v_group_name) > 64 then
    raise exception 'group name must be at most 64 characters';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_actor_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  update public.groups
  set
    "name" = v_group_name,
    "updated_at" = now()
  where "id" = p_group_id;

  get diagnostics v_updated = row_count;
  if v_updated = 0 then
    raise exception 'group not found';
  end if;
end;
$$;

create function public.group_member_remove(
  p_group_id uuid,
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_target_type public.group_user_type;
  v_deleted integer;
begin
  if v_actor_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  if p_user_id is null then
    raise exception 'user_id is required';
  end if;

  if p_user_id = v_actor_id then
    raise exception 'cannot remove yourself';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_actor_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  select gu."type"
  into v_target_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = p_user_id
  limit 1;

  if v_target_type is null then
    raise exception 'member not found';
  end if;

  if v_target_type = 'creator' then
    raise exception 'cannot remove creator';
  end if;

  delete from public.group_users
  where "group_id" = p_group_id
    and "user_id" = p_user_id;

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'member not found';
  end if;
end;
$$;

create function public.group_delete(
  p_group_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := (select auth.uid());
  v_actor_type public.group_user_type;
  v_deleted integer;
begin
  if v_actor_id is null then
    raise exception 'not authenticated';
  end if;

  if p_group_id is null then
    raise exception 'group_id is required';
  end if;

  select gu."type"
  into v_actor_type
  from public.group_users gu
  where gu."group_id" = p_group_id
    and gu."user_id" = v_actor_id
  limit 1;

  if v_actor_type is null or v_actor_type not in ('creator', 'admin') then
    raise exception 'not authorized';
  end if;

  delete from public.groups
  where "id" = p_group_id;

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'group not found';
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- Meme visibility, feed, and notification semantics for group recipients
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
    recipients."user_id",
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
  from (
    select mr."user_id"
    from public.meme_recipients mr
    where mr."meme_id" = new."id"
      and mr."user_id" is not null
    union
    select gu."user_id"
    from public.meme_recipients mr
    join public.group_users gu on gu."group_id" = mr."group_id"
    where mr."meme_id" = new."id"
      and mr."group_id" is not null
  ) recipients
  where recipients."user_id" <> new."user_id"
  on conflict do nothing;

  return new;
end;
$$;

create or replace function public.is_meme_recipient(
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
      and (
        mr."user_id" = p_user_id
        or (
          mr."group_id" is not null
          and (
            exists (
              select 1
              from public.group_users gu
              where gu."group_id" = mr."group_id"
                and gu."user_id" = p_user_id
            )
            or exists (
              select 1
              from public.group_invitations gi
              where gi."group_id" = mr."group_id"
                and gi."invitee_id" = p_user_id
                and gi."status" = 'pending'
            )
          )
        )
      )
  );
$$;

create or replace function public.can_view_meme(
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

create or replace function public.feed_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
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
    where public.can_view_meme(m."id", (select "user_id" from params))
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_own_all_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "auth_user_id"
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
        when m."user_id" = (select "auth_user_id" from params) then false
        else exists (
          select 1
          from public.meme_laughs ml
          where ml."meme_id" = m."id"
            and ml."user_id" = (select "auth_user_id" from params)
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
    where public.can_view_meme(m."id", (select "auth_user_id" from params))
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_own_sent_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "auth_user_id"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      false as "is_laughed",
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
    where m."user_id" = (select "auth_user_id" from params)
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_own_received_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select (select auth.uid()) as "auth_user_id"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      exists (
        select 1
        from public.meme_laughs ml
        where ml."meme_id" = m."id"
          and ml."user_id" = (select "auth_user_id" from params)
      ) as "is_laughed",
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
    where m."user_id" <> (select "auth_user_id" from params)
      and public.is_meme_recipient(m."id", (select "auth_user_id" from params))
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_other_all_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "auth_user_id",
      p_user_id as "target_user_id"
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
        when m."user_id" = (select "auth_user_id" from params) then false
        else exists (
          select 1
          from public.meme_laughs ml
          where ml."meme_id" = m."id"
            and ml."user_id" = (select "auth_user_id" from params)
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
    where (select "target_user_id" from params) is not null
      and (select "target_user_id" from params)
        <> (select "auth_user_id" from params)
      and (
        (
          m."user_id" = (select "auth_user_id" from params)
          and public.is_meme_recipient(
            m."id",
            (select "target_user_id" from params)
          )
        )
        or (
          m."user_id" = (select "target_user_id" from params)
          and public.is_meme_recipient(
            m."id",
            (select "auth_user_id" from params)
          )
        )
      )
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_other_sent_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "auth_user_id",
      p_user_id as "target_user_id"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      false as "is_laughed",
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
    where (select "target_user_id" from params) is not null
      and (select "target_user_id" from params)
        <> (select "auth_user_id" from params)
      and m."user_id" = (select "auth_user_id" from params)
      and public.is_meme_recipient(m."id", (select "target_user_id" from params))
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create or replace function public.user_details_memes_other_received_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "auth_user_id",
      p_user_id as "target_user_id"
  ),
  base as (
    select
      m."id" as "meme_id",
      m."created_at" as "meme_created_at",
      m."updated_at" as "meme_updated_at",
      m."image_path",
      m."aspect_ratio",
      coalesce(lc."laugh_count", 0)::integer as "laugh_count",
      exists (
        select 1
        from public.meme_laughs ml
        where ml."meme_id" = m."id"
          and ml."user_id" = (select "auth_user_id" from params)
      ) as "is_laughed",
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
    where (select "target_user_id" from params) is not null
      and (select "target_user_id" from params)
        <> (select "auth_user_id" from params)
      and m."user_id" = (select "target_user_id" from params)
      and public.is_meme_recipient(m."id", (select "auth_user_id" from params))
  ),
  ordered as (
    select
      row(
        "meme_id",
        "meme_created_at",
        "meme_updated_at",
        "image_path",
        "aspect_ratio",
        "laugh_count",
        "is_laughed",
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_item
      )::public.meme_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Notification templates
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
    'group_invitation_sent',
    'en',
    null,
    'New group invitation',
    '{sender_name} invited you to join {group_name}.'
  ),
  (
    'group_invitation_sent',
    'en',
    'US',
    'New group invitation',
    '{sender_name} invited you to join {group_name}.'
  ),
  (
    'group_invitation_sent',
    'de',
    null,
    'Neue Gruppeneinladung',
    '{sender_name} hat dich zu {group_name} eingeladen.'
  ),
  (
    'group_invitation_sent',
    'de',
    'DE',
    'Neue Gruppeneinladung',
    '{sender_name} hat dich zu {group_name} eingeladen.'
  )
on conflict ("notification_type", "language_code", "country_code")
do update
set
  "title" = excluded."title",
  "message" = excluded."message",
  "updated_at" = now();

-- -----------------------------------------------------------------------------
-- Row-level security for groups tables
-- -----------------------------------------------------------------------------

alter table public.groups enable row level security;
alter table public.group_users enable row level security;
alter table public.group_invitations enable row level security;

create policy "groups:select:member:authenticated"
on public.groups
for select
to authenticated
using (
  exists (
    select 1
    from public.group_users gu
    where gu."group_id" = public.groups."id"
      and gu."user_id" = (select auth.uid())
  )
);

create policy "group_users:select:member:authenticated"
on public.group_users
for select
to authenticated
using (
  exists (
    select 1
    from public.group_users me
    where me."group_id" = public.group_users."group_id"
      and me."user_id" = (select auth.uid())
  )
);

create policy "group_invitations:select:participant:authenticated"
on public.group_invitations
for select
to authenticated
using (
  "inviter_id" = (select auth.uid())
  or "invitee_id" = (select auth.uid())
);

-- -----------------------------------------------------------------------------
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.get_group_item(uuid) is
'Returns one group_item payload for the provided groups.id with member count.';

comment on function public.groups_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of groups that auth.uid() is currently a member of.';

comment on function public.group_invitations_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of pending group invitations addressed to auth.uid().';

comment on function public.group_create(text, uuid[]) is
'Creates one group with auth.uid() as creator and creates pending invitations for the provided invitee ids.';

comment on function public.group_invitation_accept(uuid) is
'Accepts one pending group invitation for auth.uid() and returns the joined group payload.';

comment on function public.group_invitation_reject(uuid) is
'Rejects one pending group invitation for auth.uid().';

comment on function public.group_invitation_cancel(uuid) is
'Cancels one pending group invitation when auth.uid() is the inviter or a creator/admin member of the group.';

comment on function public.group_leave(uuid) is
'Removes auth.uid() from the provided group id when more than one member exists and creator/admin exits do not leave the group without an admin.';

comment on function public.meme_recipient_targets_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated merged list of friend users and joined groups available as meme recipients for auth.uid().';

comment on function public.meme_create(text, uuid, uuid[], uuid[], double precision) is
'Creates one meme for auth.uid(), validates direct friend recipients and joined groups, and persists recipient rows with one user_id xor group_id target.';

comment on function public.sync_group_users_from_accepted_invitation() is
'Creates one group_users membership whenever a group invitation becomes accepted.';

comment on function public.cleanup_group_after_user_removed() is
'Handles group edge-cases after member removal: remove the departing member''s group-targeted meme recipients, cancel pending invitations when empty, and delete empty groups.';

comment on function public.cleanup_meme_after_recipient_removed() is
'Deletes a meme when its last meme_recipients row is removed.';

comment on function public.create_notification_on_group_invitation_sent() is
'Creates one group_invitation_sent notification row when a pending group invitation is inserted.';

comment on function public.can_access_group(uuid, uuid) is
'Returns true when the user is a group member or has a pending invitation for the group.';

comment on function public.group_details_get(uuid) is
'Returns group details for members and pending invitees, including role-based member-management and invite capabilities.';

comment on function public.group_details_memes_all_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of all memes sent to the given group for members and pending invitees.';

comment on function public.group_details_memes_sent_by_me_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes sent by auth.uid() to the given group for members and pending invitees.';

comment on function public.group_details_members_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of current group members for members and pending invitees.';

comment on function public.group_details_pending_invitations_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of pending invitations for members and pending invitees.';

comment on function public.group_invitable_friends_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of current-user friends that can be invited to the target group (excluding members and pending invitees).';

comment on function public.group_members_invite(uuid, uuid[]) is
'Creates pending invitations for one group when auth.uid() is a creator/admin and invitees are eligible friends.';

comment on function public.group_member_role_update(uuid, uuid, public.group_user_type) is
'Updates one member role to admin/member when auth.uid() is a creator/admin, excluding creator-role changes.';

comment on function public.group_member_remove(uuid, uuid) is
'Removes one non-creator member from a group when auth.uid() is a creator or admin, excluding self-removal.';

comment on function public.group_name_update(uuid, text) is
'Updates one group name when auth.uid() is a creator or admin.';

comment on function public.group_delete(uuid) is
'Deletes one group when auth.uid() is a creator or admin.';

comment on function public.create_notifications_on_meme_preview_resolved() is
'Creates meme_received notifications for direct user recipients and for current members of group recipients.';

comment on function public.is_meme_recipient(uuid, uuid) is
'Returns true when the user is a direct recipient, group member recipient, or pending invitee recipient for a meme.';

comment on function public.can_view_meme(uuid, uuid) is
'Returns true when the user is the meme creator or resolves as a meme recipient under direct/group rules.';

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.get_group_item(uuid) from public;
revoke all on function public.groups_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.group_invitations_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.group_create(text, uuid[]) from public;
revoke all on function public.group_invitation_accept(uuid) from public;
revoke all on function public.group_invitation_reject(uuid) from public;
revoke all on function public.group_invitation_cancel(uuid) from public;
revoke all on function public.group_leave(uuid) from public;
revoke all on function public.group_details_get(uuid) from public;
revoke all on function public.group_details_memes_all_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.group_details_memes_sent_by_me_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.group_details_members_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.group_details_pending_invitations_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.group_invitable_friends_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.group_members_invite(uuid, uuid[]) from public;
revoke all on function public.group_member_role_update(uuid, uuid, public.group_user_type) from public;
revoke all on function public.group_member_remove(uuid, uuid) from public;
revoke all on function public.group_name_update(uuid, text) from public;
revoke all on function public.group_delete(uuid) from public;
revoke all on function public.meme_recipient_targets_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.meme_create(text, uuid, uuid[], uuid[], double precision) from public;

grant execute on function public.get_group_item(uuid) to authenticated;
grant execute on function public.groups_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_invitations_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_create(text, uuid[]) to authenticated;
grant execute on function public.group_invitation_accept(uuid) to authenticated;
grant execute on function public.group_invitation_reject(uuid) to authenticated;
grant execute on function public.group_invitation_cancel(uuid) to authenticated;
grant execute on function public.group_leave(uuid) to authenticated;
grant execute on function public.group_details_get(uuid) to authenticated;
grant execute on function public.group_details_memes_all_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_details_memes_sent_by_me_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_details_members_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_details_pending_invitations_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_invitable_friends_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_members_invite(uuid, uuid[]) to authenticated;
grant execute on function public.group_member_role_update(uuid, uuid, public.group_user_type) to authenticated;
grant execute on function public.group_member_remove(uuid, uuid) to authenticated;
grant execute on function public.group_name_update(uuid, text) to authenticated;
grant execute on function public.group_delete(uuid) to authenticated;
grant execute on function public.meme_recipient_targets_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_create(text, uuid, uuid[], uuid[], double precision) to authenticated;
