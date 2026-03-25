alter table "public"."user_blocks" drop column "reason";

CREATE INDEX user_blocks_blocker_created_at_blocked_id_idx ON public.user_blocks USING btree (blocker_id, created_at DESC, blocked_id DESC);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.user_blocked_users_list(p_search text DEFAULT NULL::text, p_limit integer DEFAULT 30, p_cursor_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_cursor_id uuid DEFAULT NULL::uuid)
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

  return (
    with params as (
      select
        v_user_id as user_id,
        nullif(trim(p_search), '') as search_term
    ),
    base as (
      select
        ub.blocked_id,
        u.name as blocked_name,
        u.friendship_code,
        u.created_at as blocked_user_created_at,
        u.updated_at as blocked_user_updated_at,
        ub.created_at as blocked_at
      from public.user_blocks ub
      join public.users u on u.id = ub.blocked_id
      where ub.blocker_id = (select user_id from params)
    ),
    filtered as (
      select *
      from base
      where (select search_term from params) is null
        or lower(blocked_name) like '%' || lower((select search_term from params)) || '%'
        or friendship_code like '%' || (select search_term from params) || '%'
    ),
    ordered as (
      select
        row(
          blocked_id,
          blocked_name,
          friendship_code,
          blocked_user_created_at,
          blocked_user_updated_at
        )::public.user_item as item,
        blocked_at as sort_created_at,
        blocked_id as sort_id
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

revoke all on function public.user_blocked_users_list(text, integer, timestamptz, uuid) from public;

grant execute on function public.user_blocked_users_list(text, integer, timestamptz, uuid) to authenticated;
