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

create type public.user_profile as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_request_status
  as enum ('pending', 'accepted', 'declined', 'canceled');

create type public.friendship_request_list_item as (
  "user" jsonb,
  "status" public.friendship_request_status,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "direction" text,
  "id" uuid
);

create type public.friendship_list_item as (
  "user" jsonb,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_list_page as (
  "items" jsonb,
  "next_cursor_name" text,
  "next_cursor_id" uuid
);

create type public.friendship_request_list_page as (
  "items" jsonb,
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

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

create trigger trg_friendship_requests__sync_friendships_on_accepted
after insert or update of "status" on public.friendship_requests
for each row
execute function public.sync_friendships_from_accepted_request();

-- -----------------------------------------------------------------------------
-- Row-level security and policies
-- -----------------------------------------------------------------------------

alter table public.users enable row level security;
alter table public.friendships enable row level security;
alter table public.friendship_requests enable row level security;

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
-- User/profile RPCs
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
    raise exception 'current user profile not found';
  end if;
end;
$$;

create function public.get_users_profile(
  p_user_id uuid
)
returns public.user_profile
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
  )::public.user_profile
  from public.users u
  where u."id" = p_user_id
  limit 1;
$$;

create function public.get_current_users_profile()
returns public.user_profile
language sql
stable
security invoker
set search_path = public
as $$
  select public.get_users_profile((select auth.uid()));
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
          then 'outgoing'
        else 'incoming'
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
      end as "other_user_friendship_code"
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
        jsonb_build_object(
          'id',
          "other_user_id",
          'name',
          "other_user_name",
          'friendship_code',
          "other_user_friendship_code"
        ),
        "status",
        "created_at",
        "updated_at",
        "direction",
        "request_id"
      )::public.friendship_request_list_item as "item",
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
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb) as "items",
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
        jsonb_build_object(
          'id',
          "friend_id",
          'name',
          "friend_name",
          'friendship_code',
          "friendship_code"
        ),
        "created_at",
        "updated_at"
      )::public.friendship_list_item as "item",
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
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb) as "items",
    (select "next_name" from next_cursor) as "next_cursor_name",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

-- -----------------------------------------------------------------------------
-- Friendship mutation RPCs
-- -----------------------------------------------------------------------------

create function public.friendship_request_create(
  p_addressee_friendship_code text
)
returns public.friendship_request_list_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requester_id uuid := (select auth.uid());
  v_addressee_id uuid;
  v_req public.friendship_requests;
  v_result public.friendship_request_list_item;
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
    jsonb_build_object(
      'id',
      case
        when r."requester_id" = v_requester_id then r."addressee_id"
        else r."requester_id"
      end,
      'name',
      case
        when r."requester_id" = v_requester_id then ua."name"
        else ur."name"
      end,
      'friendship_code',
      case
        when r."requester_id" = v_requester_id then ua."friendship_code"
        else ur."friendship_code"
      end
    ) as "user",
    r."status",
    r."created_at",
    r."updated_at",
    case
      when r."requester_id" = v_requester_id then 'outgoing'
      else 'incoming'
    end,
    r."id"
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
returns public.friendship_list_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_addressee_id uuid := (select auth.uid());
  v_requester_id uuid;
  v_friendship_created_at timestamptz;
  v_friendship_updated_at timestamptz;
  v_result public.friendship_list_item;
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

  select f."created_at", f."updated_at"
  into v_friendship_created_at, v_friendship_updated_at
  from public.friendships f
  where f."user_id" = v_addressee_id
    and f."friend_id" = v_requester_id;

  select row(
    jsonb_build_object(
      'id',
      u."id",
      'name',
      u."name",
      'friendship_code',
      u."friendship_code"
    ),
    v_friendship_created_at,
    v_friendship_updated_at
  )::public.friendship_list_item
  into v_result
  from public.users u
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
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.update_current_user_name(text) is
'Sets public.users.name for the currently authenticated user.';

comment on function public.get_users_profile(uuid) is
'Returns one user profile payload for the provided users.id value.';

comment on function public.get_current_users_profile() is
'Returns the user profile payload for auth.uid().';

comment on function public.friendships_list(text, integer, text, uuid) is
'Returns one cursor-paginated page of active friendships for auth.uid().';

comment on function public.friendship_requests_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of pending friendship requests for auth.uid(), including request ids.';

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

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.update_current_user_name(text) from public;
revoke all on function public.get_users_profile(uuid) from public;
revoke all on function public.get_current_users_profile() from public;
revoke all on function public.friendships_list(text, integer, text, uuid) from public;
revoke all on function public.friendship_requests_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.friendship_request_create(text) from public;
revoke all on function public.friendship_request_accept(uuid) from public;
revoke all on function public.friendship_request_decline(uuid) from public;
revoke all on function public.friendship_request_cancel(uuid) from public;
revoke all on function public.friendship_delete(uuid) from public;

grant execute on function public.update_current_user_name(text) to authenticated;
grant execute on function public.get_users_profile(uuid) to authenticated;
grant execute on function public.get_current_users_profile() to authenticated;
grant execute on function public.friendships_list(text, integer, text, uuid) to authenticated;
grant execute on function public.friendship_requests_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.friendship_request_create(text) to authenticated;
grant execute on function public.friendship_request_accept(uuid) to authenticated;
grant execute on function public.friendship_request_decline(uuid) to authenticated;
grant execute on function public.friendship_request_cancel(uuid) to authenticated;
grant execute on function public.friendship_delete(uuid) to authenticated;
