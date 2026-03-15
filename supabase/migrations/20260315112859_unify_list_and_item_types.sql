-- -----------------------------------------------------------------------------
-- Unified list/item payload contracts
-- -----------------------------------------------------------------------------

create index if not exists friendships_user_id_created_at_friend_id_idx
on public.friendships ("user_id", "created_at" desc, "friend_id" desc);

-- -----------------------------------------------------------------------------
-- Drop functions that still depend on legacy composite return types
-- -----------------------------------------------------------------------------

drop function if exists public.get_users_profile(uuid);
drop function if exists public.notifications_list(text, integer, timestamptz, uuid);
drop function if exists public.friendship_requests_list(text, integer, timestamptz, uuid);
drop function if exists public.friendships_list(text, integer, text, uuid);
drop function if exists public.friendships_list(text, integer, timestamptz, uuid);
drop function if exists public.meme_templates_list(text, integer, timestamptz, uuid);
drop function if exists public.feed_list(integer, timestamptz, uuid);
drop function if exists public.meme_details_get(uuid);
drop function if exists public.meme_laughs_list(uuid, integer, timestamptz, uuid);
drop function if exists public.friendship_request_create(text);
drop function if exists public.friendship_request_accept(uuid);
drop function if exists public.user_details_memes_own_all_list(integer, timestamptz, uuid);
drop function if exists public.user_details_memes_own_sent_list(integer, timestamptz, uuid);
drop function if exists public.user_details_memes_own_received_list(integer, timestamptz, uuid);
drop function if exists public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid);
drop function if exists public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid);
drop function if exists public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid);

-- -----------------------------------------------------------------------------
-- Drop legacy composite payload types
-- -----------------------------------------------------------------------------

drop type if exists public.user_details cascade;
drop type if exists public.friendship_list_page_item_user cascade;
drop type if exists public.friendship_list_page_item cascade;
drop type if exists public.friendship_list_page cascade;
drop type if exists public.friendship_request_list_page_item_user cascade;
drop type if exists public.friendship_request_list_page_item cascade;
drop type if exists public.friendship_request_list_page cascade;
drop type if exists public.meme_template_list_page_item cascade;
drop type if exists public.meme_template_list_page cascade;
drop type if exists public.notification_list_page_item cascade;
drop type if exists public.notification_list_page cascade;
drop type if exists public.feed_list_page_item_meme cascade;
drop type if exists public.feed_list_page_item_user cascade;
drop type if exists public.feed_list_page_item cascade;
drop type if exists public.feed_list_page cascade;
drop type if exists public.meme_details_user cascade;
drop type if exists public.meme_details cascade;
drop type if exists public.meme_laugh_list_page_item_user cascade;
drop type if exists public.meme_laugh_list_page_item cascade;
drop type if exists public.meme_laugh_list_page cascade;

drop type if exists public.user_details_memes_own_all_list_page_item_meme cascade;
drop type if exists public.user_details_memes_own_all_list_page_item_user cascade;
drop type if exists public.user_details_memes_own_all_list_page_item cascade;
drop type if exists public.user_details_memes_own_all_list_page cascade;
drop type if exists public.user_details_memes_own_sent_list_page_item_meme cascade;
drop type if exists public.user_details_memes_own_sent_list_page_item_user cascade;
drop type if exists public.user_details_memes_own_sent_list_page_item cascade;
drop type if exists public.user_details_memes_own_sent_list_page cascade;
drop type if exists public.user_details_memes_own_received_list_page_item_meme cascade;
drop type if exists public.user_details_memes_own_received_list_page_item_user cascade;
drop type if exists public.user_details_memes_own_received_list_page_item cascade;
drop type if exists public.user_details_memes_own_received_list_page cascade;
drop type if exists public.user_details_memes_other_all_list_page_item_meme cascade;
drop type if exists public.user_details_memes_other_all_list_page_item_user cascade;
drop type if exists public.user_details_memes_other_all_list_page_item cascade;
drop type if exists public.user_details_memes_other_all_list_page cascade;
drop type if exists public.user_details_memes_other_sent_list_page_item_meme cascade;
drop type if exists public.user_details_memes_other_sent_list_page_item_user cascade;
drop type if exists public.user_details_memes_other_sent_list_page_item cascade;
drop type if exists public.user_details_memes_other_sent_list_page cascade;
drop type if exists public.user_details_memes_other_received_list_page_item_meme cascade;
drop type if exists public.user_details_memes_other_received_list_page_item_user cascade;
drop type if exists public.user_details_memes_other_received_list_page_item cascade;
drop type if exists public.user_details_memes_other_received_list_page cascade;

-- -----------------------------------------------------------------------------
-- Canonical API payload types
-- -----------------------------------------------------------------------------

create type public.list_page as (
  "items" jsonb,
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_item as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_item as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean,
  "user" public.user_item
);

create type public.friendship_item as (
  "user" public.user_item,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.friendship_request_item as (
  "id" uuid,
  "status" public.friendship_request_status,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "direction" public.friendship_request_direction,
  "user" public.user_item
);

create type public.meme_template_item as (
  "id" uuid,
  "image_path" text,
  "aspect_ratio" double precision,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.notification_item as (
  "id" uuid,
  "type" public.notification_type,
  "data" jsonb,
  "is_read" boolean,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.meme_laugh_item as (
  "user" public.user_item,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

-- -----------------------------------------------------------------------------
-- Recreated RPCs on unified payload types
-- -----------------------------------------------------------------------------

create function public.get_users_profile(
  p_user_id uuid
)
returns public.user_item
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
  )::public.user_item
  from public.users u
  where u."id" = p_user_id
  limit 1;
$$;

create function public.notifications_list(
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
      )::public.notification_item as "item",
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

create function public.friendship_requests_list(
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
        )::public.user_item
      )::public.friendship_request_item as "item",
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
  select row(
    coalesce(jsonb_agg(to_jsonb(paged."item")), '[]'::jsonb),
    (select "next_created_at" from next_cursor),
    (select "next_id" from next_cursor)
  )::public.list_page
  from paged;
$$;

create function public.friendships_list(
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
        )::public.user_item,
        "created_at",
        "updated_at"
      )::public.friendship_item as "item",
      "created_at" as "sort_created_at",
      "friend_id" as "sort_id"
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

create function public.meme_templates_list(
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
      )::public.meme_template_item as "item",
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

create function public.feed_list(
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

create function public.meme_details_get(
  p_meme_id uuid
)
returns public.meme_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_details public.meme_item;
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
    )::public.user_item
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
  p_cursor_id uuid default null
)
returns public.list_page
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
          )::public.user_item,
          "laugh_created_at",
          "laugh_updated_at"
        )::public.meme_laugh_item as "item",
        "laugh_created_at" as "sort_created_at",
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

create function public.friendship_request_create(
  p_addressee_friendship_code text
)
returns public.friendship_request_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requester_id uuid := (select auth.uid());
  v_addressee_id uuid;
  v_req public.friendship_requests;
  v_result public.friendship_request_item;
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
    )::public.user_item
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
returns public.friendship_item
language plpgsql
security definer
set search_path = public
as $$
declare
  v_addressee_id uuid := (select auth.uid());
  v_requester_id uuid;
  v_result public.friendship_item;
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
    )::public.user_item,
    f."created_at",
    f."updated_at"
  into
    v_result."user",
    v_result."created_at",
    v_result."updated_at"
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

create function public.user_details_memes_own_all_list(
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
    where (
      m."user_id" = (select "auth_user_id" from params)
      or exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."user_id" = (select "auth_user_id" from params)
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

create function public.user_details_memes_own_sent_list(
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

create function public.user_details_memes_own_received_list(
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
      and exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."user_id" = (select "auth_user_id" from params)
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

create function public.user_details_memes_other_all_list(
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
          and exists (
            select 1
            from public.meme_recipients mr
            where mr."meme_id" = m."id"
              and mr."user_id" = (select "target_user_id" from params)
          )
        )
        or (
          m."user_id" = (select "target_user_id" from params)
          and exists (
            select 1
            from public.meme_recipients mr
            where mr."meme_id" = m."id"
              and mr."user_id" = (select "auth_user_id" from params)
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

create function public.user_details_memes_other_sent_list(
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
      and exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."user_id" = (select "target_user_id" from params)
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

create function public.user_details_memes_other_received_list(
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
      and exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = m."id"
          and mr."user_id" = (select "auth_user_id" from params)
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

-- -----------------------------------------------------------------------------
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.user_details_memes_own_all_list(integer, timestamptz, uuid) is
'Returns one cursor-paginated page of all memes visible to auth.uid() for own-profile user details, including created and received memes.';

comment on function public.user_details_memes_own_sent_list(integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes created by auth.uid() for own-profile user details.';

comment on function public.user_details_memes_own_received_list(integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes received by auth.uid() for own-profile user details.';

comment on function public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes exchanged between auth.uid() and the provided user id for user-details tabs.';

comment on function public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes sent by auth.uid() to the provided user id for user-details tabs.';

comment on function public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of memes sent by the provided user id to auth.uid() for user-details tabs.';

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.get_users_profile(uuid) from public;
revoke all on function public.notifications_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.friendship_requests_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.friendships_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.meme_templates_list(text, integer, timestamptz, uuid) from public;
revoke all on function public.feed_list(integer, timestamptz, uuid) from public;
revoke all on function public.meme_details_get(uuid) from public;
revoke all on function public.meme_laughs_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.friendship_request_create(text) from public;
revoke all on function public.friendship_request_accept(uuid) from public;
revoke all on function public.user_details_memes_own_all_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_own_sent_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_own_received_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid) from public;

grant execute on function public.get_users_profile(uuid) to authenticated;
grant execute on function public.notifications_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.friendship_requests_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.friendships_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_templates_list(text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.feed_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_details_get(uuid) to authenticated;
grant execute on function public.meme_laughs_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.friendship_request_create(text) to authenticated;
grant execute on function public.friendship_request_accept(uuid) to authenticated;
grant execute on function public.user_details_memes_own_all_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_own_sent_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_own_received_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid) to authenticated;
