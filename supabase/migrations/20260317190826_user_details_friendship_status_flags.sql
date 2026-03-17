create type public.user_profile_item as (
  "id" uuid,
  "name" text,
  "friendship_code" text,
  "created_at" timestamptz,
  "updated_at" timestamptz,
  "is_friend" boolean,
  "has_pending_friendship_request" boolean
);

drop function if exists public.get_users_profile(uuid);

create function public.get_users_profile(
  p_user_id uuid
)
returns public.user_profile_item
language sql
stable
security invoker
set search_path = public
as $$
  with params as (
    select
      (select auth.uid()) as "viewer_id"
  )
  select row(
    u."id",
    u."name",
    u."friendship_code",
    u."created_at",
    u."updated_at",
    case
      when p."viewer_id" is null then false
      when p."viewer_id" = p_user_id then false
      else exists (
        select 1
        from public.friendships f
        where f."user_id" = p."viewer_id"
          and f."friend_id" = p_user_id
      )
    end,
    case
      when p."viewer_id" is null then false
      when p."viewer_id" = p_user_id then false
      else exists (
        select 1
        from public.friendship_requests r
        where r."status" = 'pending'
          and (
            (
              r."requester_id" = p."viewer_id"
              and r."addressee_id" = p_user_id
            )
            or (
              r."requester_id" = p_user_id
              and r."addressee_id" = p."viewer_id"
            )
          )
      )
    end
  )::public.user_profile_item
  from public.users u
  cross join params p
  where u."id" = p_user_id
  limit 1;
$$;

comment on function public.get_users_profile(uuid) is
'Returns one user details payload for the provided users.id value, including friendship relationship flags against auth.uid().';

revoke all on function public.get_users_profile(uuid) from public;
grant execute on function public.get_users_profile(uuid) to authenticated;
