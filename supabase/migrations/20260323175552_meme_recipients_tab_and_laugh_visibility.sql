drop policy "meme_laughs:select:viewable_meme:authenticated" on "public"."meme_laughs";

CREATE INDEX meme_recipients_meme_id_created_at_id_idx ON public.meme_recipients USING btree (meme_id, created_at DESC, id DESC);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.can_view_meme_laugh_actor(p_meme_id uuid, p_viewer_user_id uuid, p_actor_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    p_meme_id is not null
    and p_viewer_user_id is not null
    and p_actor_user_id is not null
    and public.can_view_meme(p_meme_id, p_viewer_user_id)
    and public.can_view_meme(p_meme_id, p_actor_user_id)
    and (
      public.is_meme_creator(p_meme_id, p_viewer_user_id)
      or p_viewer_user_id = p_actor_user_id
      or exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = p_meme_id
          and mr."group_id" is not null
          and public.can_access_group(mr."group_id", p_viewer_user_id)
          and public.can_access_group(mr."group_id", p_actor_user_id)
      )
    );
$function$
;

CREATE OR REPLACE FUNCTION public.meme_addable_recipient_targets_list(p_meme_id uuid, p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if not public.is_meme_creator(p_meme_id, v_user_id) then
    raise exception 'meme not found or not owned by user';
  end if;

  return (
    with params as (
      select
        v_user_id as "user_id",
        nullif(trim(p_search), '') as "search_term"
    ),
    group_access as (
      select
        gu."group_id",
        gu."created_at"
      from public.group_users gu
      where gu."user_id" = (select "user_id" from params)

      union all

      select
        gi."group_id",
        gi."created_at"
      from public.group_invitations gi
      where gi."invitee_id" = (select "user_id" from params)
        and gi."status" = 'pending'
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
        and not exists (
          select 1
          from public.meme_recipients mr
          where mr."meme_id" = p_meme_id
            and mr."user_id" = u."id"
        )
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
        min(ga."created_at") as "created_at",
        g."updated_at"
      from group_access ga
      join public.groups g on g."id" = ga."group_id"
      where not exists (
        select 1
        from public.meme_recipients mr
        where mr."meme_id" = p_meme_id
          and mr."group_id" = g."id"
      )
      group by g."id", g."name", g."updated_at"
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
    from paged
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.meme_recipient_remove(p_meme_id uuid, p_target_type public.meme_recipient_target_type, p_target_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid := (select auth.uid());
  v_deleted int;
  v_meme_exists boolean;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if p_target_type is null then
    raise exception 'target_type is required';
  end if;

  if p_target_id is null then
    raise exception 'target_id is required';
  end if;

  if not public.is_meme_creator(p_meme_id, v_user_id) then
    raise exception 'meme not found or not owned by user';
  end if;

  if p_target_type = 'user' then
    delete from public.meme_recipients mr
    where mr."meme_id" = p_meme_id
      and mr."user_id" = p_target_id;
  elsif p_target_type = 'group' then
    delete from public.meme_recipients mr
    where mr."meme_id" = p_meme_id
      and mr."group_id" = p_target_id;
  else
    raise exception 'invalid target_type';
  end if;

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'recipient target not found';
  end if;

  select exists (
    select 1
    from public.memes m
    where m."id" = p_meme_id
  )
  into v_meme_exists;

  return not v_meme_exists;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.meme_recipients_add(p_meme_id uuid, p_recipient_ids uuid[], p_group_ids uuid[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid := (select auth.uid());
  v_direct_recipient_ids uuid[];
  v_group_ids uuid[];
  v_actor_name text;
  v_push_preview_status public.push_preview_status;
  v_push_image_path text;
  v_meme_aspect_ratio double precision;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
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
    where not public.can_access_group(group_id, v_user_id)
  ) then
    raise exception 'all groups must be accessible to sender';
  end if;

  select
    u."name",
    m."push_preview_status",
    nullif(trim(m."push_image_path"), ''),
    m."aspect_ratio"
  into
    v_actor_name,
    v_push_preview_status,
    v_push_image_path,
    v_meme_aspect_ratio
  from public.memes m
  join public.users u on u."id" = m."user_id"
  where m."id" = p_meme_id
    and m."user_id" = v_user_id
  limit 1;

  if v_actor_name is null then
    raise exception 'meme not found or not owned by user';
  end if;

  if v_meme_aspect_ratio is null or v_meme_aspect_ratio <= 0 then
    raise exception 'meme aspect_ratio not found for meme notification';
  end if;

  if v_push_preview_status = 'ready' and v_push_image_path is null then
    raise exception 'meme push_image_path not found for ready meme notification';
  end if;

  if v_push_preview_status <> 'ready' then
    v_push_image_path := null;
  end if;

  with inserted_direct as (
    insert into public.meme_recipients ("meme_id", "user_id")
    select p_meme_id, recipient_id
    from unnest(v_direct_recipient_ids) as recipient_id
    on conflict do nothing
    returning "user_id"
  )
  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  select
    inserted_direct."user_id",
    'meme_received',
    jsonb_build_object(
      'actor_id',
      v_user_id,
      'actor_name',
      v_actor_name,
      'meme_id',
      p_meme_id,
      'push_image_path',
      v_push_image_path,
      'aspect_ratio',
      v_meme_aspect_ratio,
      'group_id',
      to_jsonb(null::uuid),
      'group_name',
      to_jsonb(null::text),
      'route_tab',
      to_jsonb(null::text)
    )
  from inserted_direct
  where inserted_direct."user_id" <> v_user_id
  on conflict do nothing;

  with inserted_groups as (
    insert into public.meme_recipients ("meme_id", "group_id")
    select p_meme_id, group_id
    from unnest(v_group_ids) as group_id
    on conflict do nothing
    returning "group_id"
  ),
  group_recipients as (
    select
      gu."user_id" as "recipient_id",
      g."id" as "group_id",
      g."name" as "group_name"
    from inserted_groups ig
    join public.groups g on g."id" = ig."group_id"
    join public.group_users gu on gu."group_id" = ig."group_id"

    union

    select
      gi."invitee_id" as "recipient_id",
      g."id" as "group_id",
      g."name" as "group_name"
    from inserted_groups ig
    join public.groups g on g."id" = ig."group_id"
    join public.group_invitations gi
      on gi."group_id" = ig."group_id"
     and gi."status" = 'pending'
  )
  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  select
    gr."recipient_id",
    'meme_received',
    jsonb_build_object(
      'actor_id',
      v_user_id,
      'actor_name',
      v_actor_name,
      'meme_id',
      p_meme_id,
      'push_image_path',
      v_push_image_path,
      'aspect_ratio',
      v_meme_aspect_ratio,
      'group_id',
      gr."group_id",
      'group_name',
      gr."group_name",
      'route_tab',
      to_jsonb(null::text)
    )
  from group_recipients gr
  where gr."recipient_id" <> v_user_id
  on conflict do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.meme_recipients_list(p_meme_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    with params as (
      select
        v_user_id as "viewer_user_id",
        public.is_meme_creator(p_meme_id, v_user_id) as "is_creator"
    ),
    base as (
      select
        mr."id" as "recipient_row_id",
        mr."created_at" as "recipient_created_at",
        mr."updated_at" as "recipient_updated_at",
        case
          when mr."user_id" is not null then 'user'::public.meme_recipient_target_type
          else 'group'::public.meme_recipient_target_type
        end as "target_type",
        coalesce(mr."user_id", mr."group_id") as "target_id",
        coalesce(u."name", g."name") as "target_name",
        case
          when mr."user_id" is not null then u."friendship_code"
          else null::text
        end as "target_friendship_code",
        case
          when mr."group_id" is not null then (
            select count(*)::integer
            from public.group_users gu_count
            where gu_count."group_id" = mr."group_id"
          )
          else null::integer
        end as "target_member_count"
      from public.meme_recipients mr
      left join public.users u on u."id" = mr."user_id"
      left join public.groups g on g."id" = mr."group_id"
      where mr."meme_id" = p_meme_id
        and (
          (select "is_creator" from params)
          or mr."user_id" = (select "viewer_user_id" from params)
          or (
            mr."group_id" is not null
            and public.can_access_group(
              mr."group_id",
              (select "viewer_user_id" from params)
            )
          )
        )
    ),
    ordered as (
      select
        row(
          "target_type",
          "target_id",
          "target_name",
          "target_friendship_code",
          "target_member_count",
          "recipient_created_at",
          "recipient_updated_at"
        )::public.meme_recipient_target_item as "item",
        "recipient_created_at" as "sort_created_at",
        "recipient_row_id" as "sort_id"
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
$function$
;

CREATE OR REPLACE FUNCTION public.feed_list(p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.group_details_memes_all_list(p_group_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.group_details_memes_sent_by_me_list(p_group_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.meme_details_get(p_meme_id uuid)
 RETURNS public.meme_item
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
  left join lateral (
    select count(*) as "laugh_count"
    from public.meme_laughs ml
    where ml."meme_id" = m."id"
      and public.can_view_meme_laugh_actor(
        m."id",
        v_user_id,
        ml."user_id"
      )
  ) lc on true
  where m."id" = p_meme_id
  limit 1;

  if v_details is null then
    raise exception 'meme not found';
  end if;

  return v_details;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.meme_laughs_list(p_meme_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
        and public.can_view_meme_laugh_actor(
          p_meme_id,
          v_user_id,
          ml."user_id"
        )
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_other_all_list(p_user_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_other_received_list(p_user_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_other_sent_list(p_user_id uuid, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_own_all_list(p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_own_received_list(p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;

CREATE OR REPLACE FUNCTION public.user_details_memes_own_sent_list(p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    left join lateral (
      select count(*) as "laugh_count"
      from public.meme_laughs ml
      where ml."meme_id" = m."id"
        and public.can_view_meme_laugh_actor(
          m."id",
          (select "auth_user_id" from params),
          ml."user_id"
        )
    ) lc on true
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
$function$
;


  create policy "meme_laughs:select:viewable_meme:authenticated"
  on "public"."meme_laughs"
  as permissive
  for select
  to authenticated
using (public.can_view_meme_laugh_actor(meme_id, ( SELECT auth.uid() AS uid), user_id));



-- -----------------------------------------------------------------------------
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.can_view_meme_laugh_actor(uuid, uuid, uuid) is
'Returns whether one laugh actor is visible to a viewer for a meme under recipient-scoped laugh visibility rules.';

comment on function public.meme_recipients_list(uuid, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of meme recipient targets visible to auth.uid() (creator sees all; non-creator sees direct-self plus accessible groups).';

comment on function public.meme_addable_recipient_targets_list(uuid, text, integer, timestamptz, uuid) is
'Returns one creator-only cursor-paginated page of addable recipient targets for a meme, excluding already selected recipients.';

comment on function public.meme_recipients_add(uuid, uuid[], uuid[]) is
'Adds one or more recipient targets to a meme owned by auth.uid(), validates friend/group eligibility, and creates immediate meme_received notifications for newly added recipients.';

comment on function public.meme_recipient_remove(uuid, public.meme_recipient_target_type, uuid) is
'Removes one recipient target from a meme owned by auth.uid() and returns true when the meme was deleted after removing the last recipient.';

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.can_view_meme_laugh_actor(uuid, uuid, uuid) from public;
revoke all on function public.meme_recipients_list(uuid, integer, timestamptz, uuid) from public;
revoke all on function public.meme_addable_recipient_targets_list(uuid, text, integer, timestamptz, uuid) from public;
revoke all on function public.meme_recipients_add(uuid, uuid[], uuid[]) from public;
revoke all on function public.meme_recipient_remove(uuid, public.meme_recipient_target_type, uuid) from public;

grant execute on function public.can_view_meme_laugh_actor(uuid, uuid, uuid) to authenticated;
grant execute on function public.meme_recipients_list(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_addable_recipient_targets_list(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.meme_recipients_add(uuid, uuid[], uuid[]) to authenticated;
grant execute on function public.meme_recipient_remove(uuid, public.meme_recipient_target_type, uuid) to authenticated;

