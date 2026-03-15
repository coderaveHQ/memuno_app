-- -----------------------------------------------------------------------------
-- User-details meme list payload types
-- -----------------------------------------------------------------------------

create type public.user_details_memes_own_all_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_own_all_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_own_all_list_page_item as (
  "meme" public.user_details_memes_own_all_list_page_item_meme,
  "user" public.user_details_memes_own_all_list_page_item_user
);

create type public.user_details_memes_own_all_list_page as (
  "items" public.user_details_memes_own_all_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_details_memes_own_sent_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_own_sent_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_own_sent_list_page_item as (
  "meme" public.user_details_memes_own_sent_list_page_item_meme,
  "user" public.user_details_memes_own_sent_list_page_item_user
);

create type public.user_details_memes_own_sent_list_page as (
  "items" public.user_details_memes_own_sent_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_details_memes_own_received_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_own_received_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_own_received_list_page_item as (
  "meme" public.user_details_memes_own_received_list_page_item_meme,
  "user" public.user_details_memes_own_received_list_page_item_user
);

create type public.user_details_memes_own_received_list_page as (
  "items" public.user_details_memes_own_received_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_details_memes_other_all_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_other_all_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_other_all_list_page_item as (
  "meme" public.user_details_memes_other_all_list_page_item_meme,
  "user" public.user_details_memes_other_all_list_page_item_user
);

create type public.user_details_memes_other_all_list_page as (
  "items" public.user_details_memes_other_all_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_details_memes_other_sent_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_other_sent_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_other_sent_list_page_item as (
  "meme" public.user_details_memes_other_sent_list_page_item_meme,
  "user" public.user_details_memes_other_sent_list_page_item_user
);

create type public.user_details_memes_other_sent_list_page as (
  "items" public.user_details_memes_other_sent_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

create type public.user_details_memes_other_received_list_page_item_meme as (
  "id" uuid,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "image_path" text,
  "aspect_ratio" double precision,
  "laugh_count" integer,
  "is_laughed" boolean
);

create type public.user_details_memes_other_received_list_page_item_user as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

create type public.user_details_memes_other_received_list_page_item as (
  "meme" public.user_details_memes_other_received_list_page_item_meme,
  "user" public.user_details_memes_other_received_list_page_item_user
);

create type public.user_details_memes_other_received_list_page as (
  "items" public.user_details_memes_other_received_list_page_item[],
  "next_cursor_created_at" timestamptz,
  "next_cursor_id" uuid
);

-- -----------------------------------------------------------------------------
-- Supporting indexes
-- -----------------------------------------------------------------------------

create index if not exists memes_user_id_created_at_id_idx
on public.memes ("user_id", "created_at" desc, "id" desc);

-- -----------------------------------------------------------------------------
-- User-details meme list RPCs
-- -----------------------------------------------------------------------------

create function public.user_details_memes_own_all_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_own_all_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_own_all_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_own_all_list_page_item_user
      )::public.user_details_memes_own_all_list_page_item as "item",
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
      '{}'::public.user_details_memes_own_all_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.user_details_memes_own_sent_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_own_sent_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_own_sent_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_own_sent_list_page_item_user
      )::public.user_details_memes_own_sent_list_page_item as "item",
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
      '{}'::public.user_details_memes_own_sent_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.user_details_memes_own_received_list(
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_own_received_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_own_received_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_own_received_list_page_item_user
      )::public.user_details_memes_own_received_list_page_item as "item",
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
      '{}'::public.user_details_memes_own_received_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.user_details_memes_other_all_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_other_all_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_other_all_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_other_all_list_page_item_user
      )::public.user_details_memes_other_all_list_page_item as "item",
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
      '{}'::public.user_details_memes_other_all_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.user_details_memes_other_sent_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_other_sent_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_other_sent_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_other_sent_list_page_item_user
      )::public.user_details_memes_other_sent_list_page_item as "item",
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
      '{}'::public.user_details_memes_other_sent_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
  from paged;
$$;

create function public.user_details_memes_other_received_list(
  p_user_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.user_details_memes_other_received_list_page
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
        row(
          "meme_id",
          "meme_created_at",
          "meme_updated_at",
          "image_path",
          "aspect_ratio",
          "laugh_count",
          "is_laughed"
        )::public.user_details_memes_other_received_list_page_item_meme,
        row(
          "creator_user_id",
          "creator_user_name",
          "creator_user_friendship_code",
          "creator_user_created_at",
          "creator_user_updated_at"
        )::public.user_details_memes_other_received_list_page_item_user
      )::public.user_details_memes_other_received_list_page_item as "item",
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
      '{}'::public.user_details_memes_other_received_list_page_item[]
    ) as "items",
    (select "next_created_at" from next_cursor) as "next_cursor_created_at",
    (select "next_id" from next_cursor) as "next_cursor_id"
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

revoke all on function public.user_details_memes_own_all_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_own_sent_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_own_received_list(integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid) from public;

grant execute on function public.user_details_memes_own_all_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_own_sent_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_own_received_list(integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_all_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_sent_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.user_details_memes_other_received_list(uuid, integer, timestamptz, uuid) to authenticated;
