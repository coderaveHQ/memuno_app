-- -----------------------------------------------------------------------------
-- Search expansion: name-only matching and group-details search signatures
-- -----------------------------------------------------------------------------

drop function if exists public.group_details_members_list(uuid, integer, timestamptz, uuid);
drop function if exists public.group_details_pending_invitations_list(uuid, integer, timestamptz, uuid);
drop function if exists public.group_invitable_friends_list(uuid, integer, timestamptz, uuid);

create function public.group_details_members_list(
  p_group_id uuid,
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
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("user_name") like '%' || lower((select "search_term" from params)) || '%'
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

create function public.group_details_pending_invitations_list(
  p_group_id uuid,
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
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or lower("invitee_name") like '%' || lower((select "search_term" from params)) || '%'
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

create function public.group_invitable_friends_list(
  p_group_id uuid,
  p_search text default null,
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
    with params as (
      select nullif(trim(p_search), '') as "search_term"
    ),
    base as (
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
    filtered as (
      select *
      from base
      where (select "search_term" from params) is null
        or lower("user_name") like '%' || lower((select "search_term" from params)) || '%'
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
$$;

create or replace function public.notifications_list(
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
      lower(coalesce(n."data"->>'actor_name', '')) as "actor_name"
    from public.notifications n
    where n."recipient_id" = (select "user_id" from params)
  ),
  filtered as (
    select *
    from base
    where (select "search_term" from params) is null
      or "actor_name" like '%' || lower((select "search_term" from params)) || '%'
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

create or replace function public.friendships_list(
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

create or replace function public.friendship_requests_list(
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

create or replace function public.meme_recipient_targets_list(
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

comment on function public.group_details_members_list(uuid, text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of current group members for members and pending invitees.';

comment on function public.group_details_pending_invitations_list(uuid, text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of pending invitations for members and pending invitees.';

comment on function public.group_invitable_friends_list(uuid, text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of current-user friends that can be invited to the target group (excluding members and pending invitees).';

revoke all on function public.group_details_members_list(uuid, text, integer, timestamptz, uuid) from public;
revoke all on function public.group_details_pending_invitations_list(uuid, text, integer, timestamptz, uuid) from public;
revoke all on function public.group_invitable_friends_list(uuid, text, integer, timestamptz, uuid) from public;

grant execute on function public.group_details_members_list(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_details_pending_invitations_list(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.group_invitable_friends_list(uuid, text, integer, timestamptz, uuid) to authenticated;
