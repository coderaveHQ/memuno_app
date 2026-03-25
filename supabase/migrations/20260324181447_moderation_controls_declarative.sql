drop function if exists "public"."meme_create"(p_image_path text, p_template_id uuid, p_recipient_ids uuid[], p_group_ids uuid[], p_aspect_ratio double precision);


  create table "public"."ugc_reports" (
    "id" uuid not null default gen_random_uuid(),
    "reporter_id" uuid not null,
    "target_type" text not null,
    "target_user_id" uuid,
    "target_meme_id" uuid,
    "reason" text not null,
    "details" text,
    "status" text not null default 'open'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."ugc_reports" enable row level security;


  create table "public"."user_blocks" (
    "blocker_id" uuid not null,
    "blocked_id" uuid not null,
    "reason" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_blocks" enable row level security;

CREATE UNIQUE INDEX pk_ugc_reports ON public.ugc_reports USING btree (id);

CREATE UNIQUE INDEX pk_user_blocks ON public.user_blocks USING btree (blocker_id, blocked_id);

CREATE INDEX ugc_reports_reporter_created_at_idx ON public.ugc_reports USING btree (reporter_id, created_at DESC, id DESC);

CREATE INDEX ugc_reports_target_meme_created_at_idx ON public.ugc_reports USING btree (target_meme_id, created_at DESC, id DESC) WHERE (target_meme_id IS NOT NULL);

CREATE INDEX ugc_reports_target_user_created_at_idx ON public.ugc_reports USING btree (target_user_id, created_at DESC, id DESC) WHERE (target_user_id IS NOT NULL);

CREATE INDEX user_blocks_blocked_id_idx ON public.user_blocks USING btree (blocked_id);

alter table "public"."ugc_reports" add constraint "pk_ugc_reports" PRIMARY KEY using index "pk_ugc_reports";

alter table "public"."user_blocks" add constraint "pk_user_blocks" PRIMARY KEY using index "pk_user_blocks";

alter table "public"."ugc_reports" add constraint "ck_ugc_reports_reason_not_empty" CHECK ((length(TRIM(BOTH FROM reason)) > 0)) not valid;

alter table "public"."ugc_reports" validate constraint "ck_ugc_reports_reason_not_empty";

alter table "public"."ugc_reports" add constraint "ck_ugc_reports_status_not_empty" CHECK ((length(TRIM(BOTH FROM status)) > 0)) not valid;

alter table "public"."ugc_reports" validate constraint "ck_ugc_reports_status_not_empty";

alter table "public"."ugc_reports" add constraint "ck_ugc_reports_target_shape" CHECK ((((target_type = 'user'::text) AND (target_user_id IS NOT NULL) AND (target_meme_id IS NULL)) OR ((target_type = 'meme'::text) AND (target_meme_id IS NOT NULL) AND (target_user_id IS NULL)))) not valid;

alter table "public"."ugc_reports" validate constraint "ck_ugc_reports_target_shape";

alter table "public"."ugc_reports" add constraint "ck_ugc_reports_target_type" CHECK ((target_type = ANY (ARRAY['user'::text, 'meme'::text]))) not valid;

alter table "public"."ugc_reports" validate constraint "ck_ugc_reports_target_type";

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_reporter" FOREIGN KEY (reporter_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_reporter";

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_target_meme" FOREIGN KEY (target_meme_id) REFERENCES public.memes(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_target_meme";

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_target_user" FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_target_user";

alter table "public"."user_blocks" add constraint "ck_user_blocks_not_self" CHECK ((blocker_id <> blocked_id)) not valid;

alter table "public"."user_blocks" validate constraint "ck_user_blocks_not_self";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.contains_prohibited_text(p_values text[])
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from unnest(coalesce(p_values, '{}'::text[])) as value
    where lower(coalesce(value, '')) ~ '(kill|kys|nazi|rape|suicide)'
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_user_blocked(p_user_id uuid, p_other_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    p_user_id is not null
    and p_other_user_id is not null
    and p_user_id <> p_other_user_id
    and exists (
      select 1
      from public.user_blocks ub
      where (
        ub.blocker_id = p_user_id
        and ub.blocked_id = p_other_user_id
      )
      or (
        ub.blocker_id = p_other_user_id
        and ub.blocked_id = p_user_id
      )
    );
$function$
;

CREATE OR REPLACE FUNCTION public.meme_create(p_image_path text, p_template_id uuid, p_recipient_ids uuid[], p_group_ids uuid[] DEFAULT '{}'::uuid[], p_aspect_ratio double precision DEFAULT NULL::double precision, p_text_layers text[] DEFAULT '{}'::text[])
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  if public.contains_prohibited_text(p_text_layers) then
    raise exception 'meme text contains prohibited terms';
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
      where f.user_id = v_user_id
        and f.friend_id = recipient_id
    )
  ) then
    raise exception 'all direct recipients must be friends';
  end if;

  if exists (
    select 1
    from unnest(v_direct_recipient_ids) as recipient_id
    where public.is_user_blocked(v_user_id, recipient_id)
  ) then
    raise exception 'cannot send memes to blocked users';
  end if;

  if exists (
    select 1
    from unnest(v_group_ids) as group_id
    where not exists (
      select 1
      from public.group_users gu
      where gu.group_id = group_id
        and gu.user_id = v_user_id
    )
  ) then
    raise exception 'all groups must include the sender';
  end if;

  if exists (
    select 1
    from unnest(v_group_ids) as group_id
    where exists (
      select 1
      from public.group_users gu
      where gu.group_id = group_id
        and public.is_user_blocked(v_user_id, gu.user_id)
    )
    or exists (
      select 1
      from public.group_invitations gi
      where gi.group_id = group_id
        and gi.status = 'pending'
        and public.is_user_blocked(v_user_id, gi.invitee_id)
    )
  ) then
    raise exception 'cannot send memes to groups containing blocked users';
  end if;

  insert into public.memes (user_id, template_id, image_path, aspect_ratio)
  values (v_user_id, p_template_id, p_image_path, p_aspect_ratio)
  returning *
  into v_meme;

  insert into public.meme_recipients (meme_id, user_id)
  select v_meme.id, recipient_id
  from unnest(v_direct_recipient_ids) as recipient_id
  on conflict do nothing;

  insert into public.meme_recipients (meme_id, group_id)
  select v_meme.id, group_id
  from unnest(v_group_ids) as group_id
  on conflict do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.ugc_report_create(p_target_type text, p_target_id uuid, p_reason text, p_details text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_reporter_id uuid := (select auth.uid());
  v_target_type text := lower(nullif(trim(p_target_type), ''));
  v_reason text := nullif(trim(p_reason), '');
  v_details text := nullif(trim(p_details), '');
begin
  if v_reporter_id is null then
    raise exception 'not authenticated';
  end if;

  if v_target_type is null then
    raise exception 'target_type is required';
  end if;

  if p_target_id is null then
    raise exception 'target_id is required';
  end if;

  if v_reason is null then
    raise exception 'reason is required';
  end if;

  if v_target_type = 'user' then
    if not exists (
      select 1
      from public.users u
      where u.id = p_target_id
    ) then
      raise exception 'target user not found';
    end if;

    insert into public.ugc_reports (
      reporter_id,
      target_type,
      target_user_id,
      reason,
      details
    )
    values (
      v_reporter_id,
      'user',
      p_target_id,
      v_reason,
      v_details
    );

    return;
  end if;

  if v_target_type = 'meme' then
    if not exists (
      select 1
      from public.memes m
      where m.id = p_target_id
    ) then
      raise exception 'target meme not found';
    end if;

    insert into public.ugc_reports (
      reporter_id,
      target_type,
      target_meme_id,
      reason,
      details
    )
    values (
      v_reporter_id,
      'meme',
      p_target_id,
      v_reason,
      v_details
    );

    return;
  end if;

  raise exception 'target_type must be `user` or `meme`';
end;
$function$
;

CREATE OR REPLACE FUNCTION public.user_block(p_target_user_id uuid)
 RETURNS void
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

  if p_target_user_id is null then
    raise exception 'target_user_id is required';
  end if;

  if p_target_user_id = v_user_id then
    raise exception 'cannot block yourself';
  end if;

  insert into public.user_blocks (blocker_id, blocked_id)
  values (v_user_id, p_target_user_id)
  on conflict (blocker_id, blocked_id)
  do update
    set updated_at = now();

  delete from public.friendship_requests r
  where r.status = 'pending'
    and (
      (
        r.requester_id = v_user_id
        and r.addressee_id = p_target_user_id
      )
      or (
        r.requester_id = p_target_user_id
        and r.addressee_id = v_user_id
      )
    );

  delete from public.friendships f
  where (
    f.user_id = v_user_id
    and f.friend_id = p_target_user_id
  )
  or (
    f.user_id = p_target_user_id
    and f.friend_id = v_user_id
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.user_is_blocked(p_target_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.user_blocks ub
    where ub.blocker_id = (select auth.uid())
      and ub.blocked_id = p_target_user_id
  );
$function$
;

CREATE OR REPLACE FUNCTION public.user_unblock(p_target_user_id uuid)
 RETURNS void
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

  if p_target_user_id is null then
    raise exception 'target_user_id is required';
  end if;

  delete from public.user_blocks ub
  where ub.blocker_id = v_user_id
    and ub.blocked_id = p_target_user_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.friendship_requests_list(p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with params as (
    select
      (select auth.uid()) as user_id,
      nullif(trim(p_search), '') as search_term
  ),
  base as (
    select
      r.id as request_id,
      r.status,
      r.created_at,
      r.updated_at,
      case
        when r.requester_id = (select user_id from params)
          then 'outgoing'::public.friendship_request_direction
        else 'incoming'::public.friendship_request_direction
      end as direction,
      case
        when r.requester_id = (select user_id from params)
          then r.addressee_id
        else r.requester_id
      end as other_user_id,
      case
        when r.requester_id = (select user_id from params)
          then ua.name
        else ur.name
      end as other_user_name,
      case
        when r.requester_id = (select user_id from params)
          then ua.friendship_code
        else ur.friendship_code
      end as other_user_friendship_code,
      case
        when r.requester_id = (select user_id from params)
          then ua.created_at
        else ur.created_at
      end as other_user_created_at,
      case
        when r.requester_id = (select user_id from params)
          then ua.updated_at
        else ur.updated_at
      end as other_user_updated_at
    from public.friendship_requests r
    join public.users ur on ur.id = r.requester_id
    join public.users ua on ua.id = r.addressee_id
    where (
      r.requester_id = (select user_id from params)
      or r.addressee_id = (select user_id from params)
    )
      and r.status = 'pending'
      and not public.is_user_blocked(
        (select user_id from params),
        case
          when r.requester_id = (select user_id from params)
            then r.addressee_id
          else r.requester_id
        end
      )
  ),
  filtered as (
    select *
    from base
    where (select search_term from params) is null
      or lower(other_user_name) like '%' || lower((select search_term from params)) || '%'
  ),
  ordered as (
    select
      row(
        request_id,
        status,
        created_at,
        updated_at,
        direction,
        row(
          other_user_id,
          other_user_name,
          other_user_friendship_code,
          other_user_created_at,
          other_user_updated_at
        )::public.user_item
      )::public.friendship_request_item as item,
      created_at as sort_created_at,
      request_id as sort_id
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (sort_created_at, sort_id) < (p_cursor_created_at, p_cursor_id)
    )
    order by sort_created_at desc, sort_id desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      sort_created_at as next_created_at,
      sort_id as next_id
    from paged
    order by sort_created_at asc, sort_id asc
    limit 1
  )
  select row(
    coalesce(jsonb_agg(to_jsonb(paged.item)), '[]'::jsonb),
    (select next_created_at from next_cursor),
    (select next_id from next_cursor)
  )::public.list_page
  from paged;
$function$
;

CREATE OR REPLACE FUNCTION public.friendships_list(p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with params as (
    select
      (select auth.uid()) as user_id,
      nullif(trim(p_search), '') as search_term
  ),
  base as (
    select
      f.friend_id,
      u.name as friend_name,
      u.friendship_code as friendship_code,
      u.created_at as friend_created_at,
      u.updated_at as friend_updated_at,
      f.created_at,
      f.updated_at
    from public.friendships f
    join public.users u on u.id = f.friend_id
    where f.user_id = (select user_id from params)
      and not public.is_user_blocked((select user_id from params), f.friend_id)
  ),
  filtered as (
    select *
    from base
    where (select search_term from params) is null
      or lower(friend_name) like '%' || lower((select search_term from params)) || '%'
  ),
  ordered as (
    select
      row(
        row(
          friend_id,
          friend_name,
          friendship_code,
          friend_created_at,
          friend_updated_at
        )::public.user_item,
        created_at,
        updated_at
      )::public.friendship_item as item,
      created_at as sort_created_at,
      friend_id as sort_id
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (sort_created_at, sort_id) < (p_cursor_created_at, p_cursor_id)
    )
    order by sort_created_at desc, sort_id desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      sort_created_at as next_created_at,
      sort_id as next_id
    from paged
    order by sort_created_at asc, sort_id asc
    limit 1
  )
  select row(
    coalesce(jsonb_agg(to_jsonb(paged.item)), '[]'::jsonb),
    (select next_created_at from next_cursor),
    (select next_id from next_cursor)
  )::public.list_page
  from paged;
$function$
;

CREATE OR REPLACE FUNCTION public.is_meme_recipient(p_meme_id uuid, p_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.meme_recipients mr
    join public.memes m on m.id = mr.meme_id
    where mr.meme_id = p_meme_id
      and not public.is_user_blocked(m.user_id, p_user_id)
      and (
        mr.user_id = p_user_id
        or (
          mr.group_id is not null
          and (
            exists (
              select 1
              from public.group_users gu
              where gu.group_id = mr.group_id
                and gu.user_id = p_user_id
            )
            or exists (
              select 1
              from public.group_invitations gi
              where gi.group_id = mr.group_id
                and gi.invitee_id = p_user_id
                and gi.status = 'pending'
            )
          )
        )
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
        v_user_id as user_id,
        nullif(trim(p_search), '') as search_term
    ),
    group_access as (
      select
        gu.group_id,
        gu.created_at
      from public.group_users gu
      where gu.user_id = (select user_id from params)

      union all

      select
        gi.group_id,
        gi.created_at
      from public.group_invitations gi
      where gi.invitee_id = (select user_id from params)
        and gi.status = 'pending'
    ),
    user_targets as (
      select
        'user'::public.meme_recipient_target_type as type,
        u.id,
        u.name,
        u.friendship_code,
        null::integer as member_count,
        f.created_at,
        f.updated_at
      from public.friendships f
      join public.users u on u.id = f.friend_id
      where f.user_id = (select user_id from params)
        and not public.is_user_blocked((select user_id from params), u.id)
        and not exists (
          select 1
          from public.meme_recipients mr
          where mr.meme_id = p_meme_id
            and mr.user_id = u.id
        )
    ),
    group_targets as (
      select
        'group'::public.meme_recipient_target_type as type,
        g.id,
        g.name,
        null::text as friendship_code,
        (
          select count(*)::integer
          from public.group_users gu_count
          where gu_count.group_id = g.id
        ) as member_count,
        min(ga.created_at) as created_at,
        g.updated_at
      from group_access ga
      join public.groups g on g.id = ga.group_id
      where not exists (
        select 1
        from public.meme_recipients mr
        where mr.meme_id = p_meme_id
          and mr.group_id = g.id
      )
        and not exists (
          select 1
          from public.group_users gu
          where gu.group_id = g.id
            and public.is_user_blocked((select user_id from params), gu.user_id)
        )
        and not exists (
          select 1
          from public.group_invitations gi
          where gi.group_id = g.id
            and gi.status = 'pending'
            and public.is_user_blocked((select user_id from params), gi.invitee_id)
        )
      group by g.id, g.name, g.updated_at
    ),
    base as (
      select * from user_targets
      union all
      select * from group_targets
    ),
    filtered as (
      select *
      from base
      where (select search_term from params) is null
        or lower(name) like '%' || lower((select search_term from params)) || '%'
        or coalesce(friendship_code, '') like '%' || (select search_term from params) || '%'
    ),
    ordered as (
      select
        row(
          type,
          id,
          name,
          friendship_code,
          member_count,
          created_at,
          updated_at
        )::public.meme_recipient_target_item as item,
        created_at as sort_created_at,
        id as sort_id
      from filtered
    ),
    paged as (
      select *
      from ordered
      where (
        p_cursor_created_at is null
        or p_cursor_id is null
        or (sort_created_at, sort_id) < (p_cursor_created_at, p_cursor_id)
      )
      order by sort_created_at desc, sort_id desc
      limit coalesce(p_limit, 30)
    ),
    next_cursor as (
      select
        sort_created_at as next_created_at,
        sort_id as next_id
      from paged
      order by sort_created_at asc, sort_id asc
      limit 1
    )
    select row(
      coalesce(jsonb_agg(to_jsonb(paged.item)), '[]'::jsonb),
      (select next_created_at from next_cursor),
      (select next_id from next_cursor)
    )::public.list_page
    from paged
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.meme_recipient_targets_list(p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with params as (
    select
      (select auth.uid()) as user_id,
      nullif(trim(p_search), '') as search_term
  ),
  user_targets as (
    select
      'user'::public.meme_recipient_target_type as type,
      u.id,
      u.name,
      u.friendship_code,
      null::integer as member_count,
      f.created_at,
      f.updated_at
    from public.friendships f
    join public.users u on u.id = f.friend_id
    where f.user_id = (select user_id from params)
      and not public.is_user_blocked((select user_id from params), u.id)
  ),
  group_targets as (
    select
      'group'::public.meme_recipient_target_type as type,
      g.id,
      g.name,
      null::text as friendship_code,
      (
        select count(*)::integer
        from public.group_users gu_count
        where gu_count.group_id = g.id
      ) as member_count,
      gu_me.created_at,
      g.updated_at
    from public.group_users gu_me
    join public.groups g on g.id = gu_me.group_id
    where gu_me.user_id = (select user_id from params)
      and not exists (
        select 1
        from public.group_users gu
        where gu.group_id = g.id
          and public.is_user_blocked((select user_id from params), gu.user_id)
      )
      and not exists (
        select 1
        from public.group_invitations gi
        where gi.group_id = g.id
          and gi.status = 'pending'
          and public.is_user_blocked((select user_id from params), gi.invitee_id)
      )
  ),
  base as (
    select * from user_targets
    union all
    select * from group_targets
  ),
  filtered as (
    select *
    from base
    where (select search_term from params) is null
      or lower(name) like '%' || lower((select search_term from params)) || '%'
  ),
  ordered as (
    select
      row(
        type,
        id,
        name,
        friendship_code,
        member_count,
        created_at,
        updated_at
      )::public.meme_recipient_target_item as item,
      created_at as sort_created_at,
      id as sort_id
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (sort_created_at, sort_id) < (p_cursor_created_at, p_cursor_id)
    )
    order by sort_created_at desc, sort_id desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      sort_created_at as next_created_at,
      sort_id as next_id
    from paged
    order by sort_created_at asc, sort_id asc
    limit 1
  )
  select row(
    coalesce(jsonb_agg(to_jsonb(paged.item)), '[]'::jsonb),
    (select next_created_at from next_cursor),
    (select next_id from next_cursor)
  )::public.list_page
  from paged;
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
      where f.user_id = v_user_id
        and f.friend_id = recipient_id
    )
  ) then
    raise exception 'all direct recipients must be friends';
  end if;

  if exists (
    select 1
    from unnest(v_direct_recipient_ids) as recipient_id
    where public.is_user_blocked(v_user_id, recipient_id)
  ) then
    raise exception 'cannot send memes to blocked users';
  end if;

  if exists (
    select 1
    from unnest(v_group_ids) as group_id
    where not public.can_access_group(group_id, v_user_id)
  ) then
    raise exception 'all groups must be accessible to sender';
  end if;

  if exists (
    select 1
    from unnest(v_group_ids) as group_id
    where exists (
      select 1
      from public.group_users gu
      where gu.group_id = group_id
        and public.is_user_blocked(v_user_id, gu.user_id)
    )
    or exists (
      select 1
      from public.group_invitations gi
      where gi.group_id = group_id
        and gi.status = 'pending'
        and public.is_user_blocked(v_user_id, gi.invitee_id)
    )
  ) then
    raise exception 'cannot send memes to groups containing blocked users';
  end if;

  select
    u.name,
    m.push_preview_status,
    nullif(trim(m.push_image_path), ''),
    m.aspect_ratio
  into
    v_actor_name,
    v_push_preview_status,
    v_push_image_path,
    v_meme_aspect_ratio
  from public.memes m
  join public.users u on u.id = m.user_id
  where m.id = p_meme_id
    and m.user_id = v_user_id
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
    insert into public.meme_recipients (meme_id, user_id)
    select p_meme_id, recipient_id
    from unnest(v_direct_recipient_ids) as recipient_id
    on conflict do nothing
    returning user_id
  )
  insert into public.notifications (
    recipient_id,
    type,
    data
  )
  select
    inserted_direct.user_id,
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
  where inserted_direct.user_id <> v_user_id
  on conflict do nothing;

  with inserted_groups as (
    insert into public.meme_recipients (meme_id, group_id)
    select p_meme_id, group_id
    from unnest(v_group_ids) as group_id
    on conflict do nothing
    returning group_id
  ),
  group_recipients as (
    select
      gu.user_id as recipient_id,
      g.id as group_id,
      g.name as group_name
    from inserted_groups ig
    join public.groups g on g.id = ig.group_id
    join public.group_users gu on gu.group_id = ig.group_id

    union

    select
      gi.invitee_id as recipient_id,
      g.id as group_id,
      g.name as group_name
    from inserted_groups ig
    join public.groups g on g.id = ig.group_id
    join public.group_invitations gi
      on gi.group_id = ig.group_id
     and gi.status = 'pending'
  )
  insert into public.notifications (
    recipient_id,
    type,
    data
  )
  select
    gr.recipient_id,
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
      gr.group_id,
      'group_name',
      gr.group_name,
      'route_tab',
      to_jsonb(null::text)
    )
  from group_recipients gr
  where gr.recipient_id <> v_user_id
  on conflict do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.notifications_list(p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
 RETURNS public.list_page
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with params as (
    select
      (select auth.uid()) as user_id,
      nullif(trim(p_search), '') as search_term
  ),
  base as (
    select
      n.id,
      n.type,
      n.data,
      n.is_read,
      n.created_at,
      n.updated_at,
      lower(coalesce(n.data->>'actor_name', '')) as actor_name
    from public.notifications n
    where n.recipient_id = (select user_id from params)
      and (
        not (n.data ? 'actor_id')
        or (n.data->>'actor_id') !~* '^[0-9a-fA-F-]{36}$'
        or not public.is_user_blocked(
          (select user_id from params),
          (n.data->>'actor_id')::uuid
        )
      )
  ),
  filtered as (
    select *
    from base
    where (select search_term from params) is null
      or actor_name like '%' || lower((select search_term from params)) || '%'
  ),
  ordered as (
    select
      row(
        id,
        type,
        data,
        is_read,
        created_at,
        updated_at
      )::public.notification_item as item,
      created_at as sort_created_at,
      id as sort_id
    from filtered
  ),
  paged as (
    select *
    from ordered
    where (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (sort_created_at, sort_id) < (p_cursor_created_at, p_cursor_id)
    )
    order by sort_created_at desc, sort_id desc
    limit coalesce(p_limit, 30)
  ),
  next_cursor as (
    select
      sort_created_at as next_created_at,
      sort_id as next_id
    from paged
    order by sort_created_at asc, sort_id asc
    limit 1
  )
  select row(
    coalesce(jsonb_agg(to_jsonb(paged.item)), '[]'::jsonb),
    (select next_created_at from next_cursor),
    (select next_id from next_cursor)
  )::public.list_page
  from paged;
$function$
;

CREATE OR REPLACE FUNCTION public.notifications_unread_count()
 RETURNS integer
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select count(*)::integer
  from public.notifications n
  where n.recipient_id = (select auth.uid())
    and n.is_read = false
    and (
      not (n.data ? 'actor_id')
      or (n.data->>'actor_id') !~* '^[0-9a-fA-F-]{36}$'
      or not public.is_user_blocked(
        (select auth.uid()),
        (n.data->>'actor_id')::uuid
      )
    );
$function$
;

grant delete on table "public"."ugc_reports" to "anon";

grant insert on table "public"."ugc_reports" to "anon";

grant references on table "public"."ugc_reports" to "anon";

grant select on table "public"."ugc_reports" to "anon";

grant trigger on table "public"."ugc_reports" to "anon";

grant truncate on table "public"."ugc_reports" to "anon";

grant update on table "public"."ugc_reports" to "anon";

grant delete on table "public"."ugc_reports" to "authenticated";

grant insert on table "public"."ugc_reports" to "authenticated";

grant references on table "public"."ugc_reports" to "authenticated";

grant select on table "public"."ugc_reports" to "authenticated";

grant trigger on table "public"."ugc_reports" to "authenticated";

grant truncate on table "public"."ugc_reports" to "authenticated";

grant update on table "public"."ugc_reports" to "authenticated";

grant delete on table "public"."ugc_reports" to "service_role";

grant insert on table "public"."ugc_reports" to "service_role";

grant references on table "public"."ugc_reports" to "service_role";

grant select on table "public"."ugc_reports" to "service_role";

grant trigger on table "public"."ugc_reports" to "service_role";

grant truncate on table "public"."ugc_reports" to "service_role";

grant update on table "public"."ugc_reports" to "service_role";

grant delete on table "public"."user_blocks" to "anon";

grant insert on table "public"."user_blocks" to "anon";

grant references on table "public"."user_blocks" to "anon";

grant select on table "public"."user_blocks" to "anon";

grant trigger on table "public"."user_blocks" to "anon";

grant truncate on table "public"."user_blocks" to "anon";

grant update on table "public"."user_blocks" to "anon";

grant delete on table "public"."user_blocks" to "authenticated";

grant insert on table "public"."user_blocks" to "authenticated";

grant references on table "public"."user_blocks" to "authenticated";

grant select on table "public"."user_blocks" to "authenticated";

grant trigger on table "public"."user_blocks" to "authenticated";

grant truncate on table "public"."user_blocks" to "authenticated";

grant update on table "public"."user_blocks" to "authenticated";

grant delete on table "public"."user_blocks" to "service_role";

grant insert on table "public"."user_blocks" to "service_role";

grant references on table "public"."user_blocks" to "service_role";

grant select on table "public"."user_blocks" to "service_role";

grant trigger on table "public"."user_blocks" to "service_role";

grant truncate on table "public"."user_blocks" to "service_role";

grant update on table "public"."user_blocks" to "service_role";


  create policy "ugc_reports:insert:self:authenticated"
  on "public"."ugc_reports"
  as permissive
  for insert
  to authenticated
with check ((reporter_id = ( SELECT auth.uid() AS uid)));



  create policy "ugc_reports:select:self:authenticated"
  on "public"."ugc_reports"
  as permissive
  for select
  to authenticated
using ((reporter_id = ( SELECT auth.uid() AS uid)));



  create policy "user_blocks:delete:self:authenticated"
  on "public"."user_blocks"
  as permissive
  for delete
  to authenticated
using ((blocker_id = ( SELECT auth.uid() AS uid)));



  create policy "user_blocks:insert:self:authenticated"
  on "public"."user_blocks"
  as permissive
  for insert
  to authenticated
with check ((blocker_id = ( SELECT auth.uid() AS uid)));



  create policy "user_blocks:select:self:authenticated"
  on "public"."user_blocks"
  as permissive
  for select
  to authenticated
using ((blocker_id = ( SELECT auth.uid() AS uid)));



