set check_function_bodies = false;

CREATE OR REPLACE FUNCTION "public"."build_meme_template_tags_search_text"("p_tags" "text"[]) RETURNS "text"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public', 'extensions'
    AS $$
  with normalized as (
    select
      lower(trim(tag)) as "tag",
      lower(trim(extensions.unaccent(trim(tag)))) as "tag_unaccented",
      min(ord) as "first_ord"
    from unnest(coalesce(p_tags, '{}'::text[])) with ordinality as t(tag, ord)
    where tag is not null
      and length(trim(tag)) > 0
    group by
      lower(trim(tag)),
      lower(trim(extensions.unaccent(trim(tag))))
  ),
  expanded as (
    select
      normalized."tag" as "token",
      normalized."first_ord" as "first_ord",
      0 as "variant_ord"
    from normalized

    union all

    select
      normalized."tag_unaccented" as "token",
      normalized."first_ord" as "first_ord",
      1 as "variant_ord"
    from normalized
    where normalized."tag_unaccented" <> normalized."tag"
  ),
  deduplicated as (
    select
      expanded."token",
      min(expanded."first_ord") as "first_ord",
      min(expanded."variant_ord") as "variant_ord"
    from expanded
    group by expanded."token"
  )
  select coalesce(
    string_agg(
      deduplicated."token",
      ' '
      order by deduplicated."first_ord", deduplicated."variant_ord", deduplicated."token"
    ),
    ''
  )
  from deduplicated;
$$;







CREATE OR REPLACE FUNCTION "public"."can_access_group"("p_group_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."can_view_meme"("p_meme_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select public.is_meme_creator(p_meme_id, p_user_id)
     or public.is_meme_recipient(p_meme_id, p_user_id);
$$;







CREATE OR REPLACE FUNCTION "public"."can_view_meme_laugh_actor"("p_meme_id" "uuid", "p_viewer_user_id" "uuid", "p_actor_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."cleanup_group_after_user_removed"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."cleanup_meme_after_recipient_removed"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."create_notification_on_friendship_request_accepted"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_actor public.users;
begin
  if new."status" <> 'accepted' or old."status" = new."status" then
    return new;
  end if;

  select *
  into v_actor
  from public.users u
  where u."id" = new."addressee_id";

  if v_actor."id" is null then
    raise exception 'addressee profile not found for friendship accepted notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    new."requester_id",
    'friendship_request_accepted',
    jsonb_build_object(
      'actor_id',
      v_actor."id",
      'actor_name',
      v_actor."name",
      'actor_friendship_code',
      v_actor."friendship_code",
      'request_id',
      new."id",
      'route_tab',
      'friendships'
    )
  );

  return new;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."create_notification_on_friendship_request_sent"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_actor public.users;
begin
  if new."status" <> 'pending' then
    return new;
  end if;

  select *
  into v_actor
  from public.users u
  where u."id" = new."requester_id";

  if v_actor."id" is null then
    raise exception 'requester profile not found for friendship request notification';
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    new."addressee_id",
    'friendship_request_sent',
    jsonb_build_object(
      'actor_id',
      v_actor."id",
      'actor_name',
      v_actor."name",
      'actor_friendship_code',
      v_actor."friendship_code",
      'request_id',
      new."id",
      'route_tab',
      'requests'
    )
  );

  return new;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."create_notification_on_group_invitation_sent"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."create_notification_on_meme_laughed"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_actor_name text;
  v_meme_owner_id uuid;
  v_push_image_path text;
  v_meme_aspect_ratio double precision;
begin
  select u."name"
  into v_actor_name
  from public.users u
  where u."id" = new."user_id";

  if v_actor_name is null then
    raise exception 'meme laugh actor profile not found for meme_laughed notification';
  end if;

  select
    m."user_id",
    nullif(trim(m."push_image_path"), ''),
    m."aspect_ratio"
  into
    v_meme_owner_id,
    v_push_image_path,
    v_meme_aspect_ratio
  from public.memes m
  where m."id" = new."meme_id";

  if v_meme_owner_id is null then
    raise exception 'meme not found for meme_laughed notification';
  end if;

  if v_meme_aspect_ratio is null or v_meme_aspect_ratio <= 0 then
    raise exception 'meme aspect_ratio not found for meme_laughed notification';
  end if;

  if v_meme_owner_id = new."user_id" then
    return new;
  end if;

  insert into public.notifications (
    "recipient_id",
    "type",
    "data"
  )
  values (
    v_meme_owner_id,
    'meme_laughed',
    jsonb_build_object(
      'actor_id',
      new."user_id",
      'actor_name',
      v_actor_name,
      'meme_id',
      new."meme_id",
      'push_image_path',
      v_push_image_path,
      'aspect_ratio',
      v_meme_aspect_ratio,
      'route_tab',
      to_jsonb(null::text)
    )
  );

  return new;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."create_notifications_on_meme_preview_resolved"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."enqueue_generate_meme_push_preview"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  perform public.invoke_internal_edge_function(
    'generate-meme-push-preview',
    jsonb_build_object(
      'type', tg_op,
      'table', tg_table_name,
      'schema', tg_table_schema,
      'record', to_jsonb(new)
    )
  );

  return new;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."enqueue_send_notification_push"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  perform public.invoke_internal_edge_function(
    'send-notification-push',
    jsonb_build_object(
      'type', tg_op,
      'table', tg_table_name,
      'schema', tg_table_schema,
      'record', to_jsonb(new)
    )
  );

  return new;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."feed_list"("p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."friendship_delete"("p_friend_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."friendship_request_accept"("p_request_id" "uuid") RETURNS "public"."friendship_item"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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




CREATE OR REPLACE FUNCTION "public"."friendship_request_cancel"("p_request_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."friendship_request_create"("p_addressee_friendship_code" "text") RETURNS "public"."friendship_request_item"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
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
$_$;




CREATE OR REPLACE FUNCTION "public"."friendship_request_decline"("p_request_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."friendship_requests_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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




CREATE OR REPLACE FUNCTION "public"."friendships_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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




CREATE OR REPLACE FUNCTION "public"."generate_friendship_code"() RETURNS "text"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_code text;
begin
  v_code := lpad((floor(random() * 100000000))::int::text, 8, '0');
  return v_code;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."get_group_item"("p_group_id" "uuid") RETURNS "public"."group_item"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."get_required_vault_secret"("p_secret_name" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'vault'
    AS $$
declare
  v_secret_value text;
begin
  select ds.decrypted_secret
  into v_secret_value
  from vault.decrypted_secrets ds
  where ds.name = p_secret_name
  order by ds.created_at desc
  limit 1;

  if v_secret_value is null then
    raise exception 'Vault secret "%" is required.', p_secret_name;
  end if;

  return v_secret_value;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."get_users_profile"("p_user_id" "uuid") RETURNS "public"."user_profile_item"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_create"("p_name" "text", "p_invitee_ids" "uuid"[] DEFAULT '{}'::"uuid"[]) RETURNS "public"."group_item"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_delete"("p_group_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_details_get"("p_group_id" "uuid") RETURNS "public"."group_details"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_details_members_list"("p_group_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_details_memes_all_list"("p_group_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."group_details_memes_sent_by_me_list"("p_group_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."group_details_pending_invitations_list"("p_group_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_invitable_friends_list"("p_group_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_invitation_accept"("p_invitation_id" "uuid") RETURNS "public"."group_item"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_invitation_cancel"("p_invitation_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_invitation_reject"("p_invitation_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_invitations_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_leave"("p_group_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_member_remove"("p_group_id" "uuid", "p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_member_role_update"("p_group_id" "uuid", "p_user_id" "uuid", "p_type" "public"."group_user_type") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_members_invite"("p_group_id" "uuid", "p_invitee_ids" "uuid"[] DEFAULT '{}'::"uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."group_name_update"("p_group_id" "uuid", "p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."groups_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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




CREATE OR REPLACE FUNCTION "public"."invoke_internal_edge_function"("p_function_name" "text", "p_payload" "jsonb" DEFAULT '{}'::"jsonb", "p_timeout_milliseconds" integer DEFAULT 10000) RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'vault'
    AS $$
declare
  v_base_url text;
  v_apikey text;
  v_request_id bigint;
begin
  v_base_url := public.get_required_vault_secret('edge_functions_base_url');
  v_apikey := public.get_required_vault_secret('edge_functions_apikey');

  select net.http_post(
    url := rtrim(v_base_url, '/') || '/functions/v1/' || p_function_name,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', v_apikey
    ),
    body := coalesce(p_payload, '{}'::jsonb),
    timeout_milliseconds := p_timeout_milliseconds
  )
  into v_request_id;

  return v_request_id;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."is_meme_creator"("p_meme_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.memes m
    where m."id" = p_meme_id
      and m."user_id" = p_user_id
  );
$$;







CREATE OR REPLACE FUNCTION "public"."is_meme_recipient"("p_meme_id" "uuid", "p_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."meme_create"("p_image_path" "text", "p_template_id" "uuid", "p_recipient_ids" "uuid"[], "p_group_ids" "uuid"[] DEFAULT '{}'::"uuid"[], "p_aspect_ratio" double precision DEFAULT NULL::double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."meme_delete"("p_meme_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid := (select auth.uid());
  v_deleted int;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  delete from public.memes m
  where m."id" = p_meme_id
    and m."user_id" = v_user_id;

  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    raise exception 'meme not found or not owned by user';
  end if;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."meme_details_get"("p_meme_id" "uuid") RETURNS "public"."meme_item"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_laugh_toggle"("p_meme_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_meme_id is null then
    raise exception 'meme_id is required';
  end if;

  if public.is_meme_creator(p_meme_id, v_user_id) then
    raise exception 'cannot laugh own meme';
  end if;

  if not public.can_view_meme(p_meme_id, v_user_id) then
    raise exception 'meme not visible';
  end if;

  if exists (
    select 1
    from public.meme_laughs ml
    where ml."meme_id" = p_meme_id
      and ml."user_id" = v_user_id
  ) then
    delete from public.meme_laughs
    where "meme_id" = p_meme_id
      and "user_id" = v_user_id;

    return false;
  end if;

  insert into public.meme_laughs ("meme_id", "user_id")
  values (p_meme_id, v_user_id)
  on conflict do nothing;

  return true;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."meme_laughs_list"("p_meme_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_recipients_list"("p_meme_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_addable_recipient_targets_list"("p_meme_id" "uuid", "p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_recipients_add"("p_meme_id" "uuid", "p_recipient_ids" "uuid"[], "p_group_ids" "uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_recipient_remove"("p_meme_id" "uuid", "p_target_type" "public"."meme_recipient_target_type", "p_target_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;




CREATE OR REPLACE FUNCTION "public"."meme_recipient_targets_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."meme_templates_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
  with params as (
    select
      nullif(trim(p_search), '') as "search_term_raw",
      lower(nullif(trim(p_search), '')) as "search_term_lower",
      lower(
        nullif(
          trim(extensions.unaccent(nullif(trim(p_search), ''))),
          ''
        )
      ) as "search_term_unaccented"
  ),
  base as (
    select
      t."id",
      t."image_path",
      t."aspect_ratio",
      t."created_at",
      t."updated_at",
      t."tags_search_text",
      case
        when (select "search_term_raw" from params) is null then 0
        when t."tags" @> array[(select "search_term_lower" from params)]::text[] then 4
        when exists (
          select 1
          from unnest(t."tags") as tag
          where lower(trim(tag)) = (select "search_term_lower" from params)
             or lower(trim(extensions.unaccent(trim(tag)))) = (select "search_term_unaccented" from params)
        ) then 3
        when t."tags_search_text" like '%' || (select "search_term_lower" from params) || '%' then 2
        when t."tags_search_text" like '%' || (select "search_term_unaccented" from params) || '%' then 1
        else 0
      end as "match_priority",
      greatest(
        similarity(
          t."tags_search_text",
          coalesce((select "search_term_lower" from params), '')
        ),
        similarity(
          t."tags_search_text",
          coalesce((select "search_term_unaccented" from params), '')
        )
      ) as "match_similarity"
    from public.meme_templates t
    where t."is_active" = true
      and (
        (select "search_term_raw" from params) is null
        or t."tags" @> array[(select "search_term_lower" from params)]::text[]
        or t."tags_search_text" ilike '%' || (select "search_term_lower" from params) || '%'
        or t."tags_search_text" ilike '%' || (select "search_term_unaccented" from params) || '%'
        or exists (
          select 1
          from unnest(t."tags") as tag
          where lower(trim(tag)) = (select "search_term_lower" from params)
             or lower(trim(extensions.unaccent(trim(tag)))) = (select "search_term_unaccented" from params)
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
      "id" as "sort_id",
      "match_priority",
      "match_similarity"
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
    order by
      case
        when (select "search_term_raw" from params) is null then 0
        else "match_priority"
      end desc,
      case
        when (select "search_term_raw" from params) is null then 0
        else "match_similarity"
      end desc,
      "sort_created_at" desc,
      "sort_id" desc
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







CREATE OR REPLACE FUNCTION "public"."notification_mark_read"("p_notification_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  if p_notification_id is null then
    raise exception 'notification_id is required';
  end if;

  update public.notifications
  set "is_read" = true,
      "updated_at" = now()
  where "id" = p_notification_id
    and "recipient_id" = v_user_id
    and "is_read" = false;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."notifications_list"("p_search" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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




CREATE OR REPLACE FUNCTION "public"."notifications_mark_all_read"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid := (select auth.uid());
  v_updated integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  update public.notifications
  set "is_read" = true,
      "updated_at" = now()
  where "recipient_id" = v_user_id
    and "is_read" = false;

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."notifications_unread_count"() RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select count(*)::integer
  from public.notifications n
  where n."recipient_id" = (select auth.uid())
    and n."is_read" = false;
$$;







CREATE OR REPLACE FUNCTION "public"."push_token_deactivate_current_device"("p_installation_id" "text", "p_reason" "public"."push_token_deactivation_reason" DEFAULT 'signed_out'::"public"."push_token_deactivation_reason") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_user_id uuid := (select auth.uid());
  v_installation_id text;
  v_reason public.push_token_deactivation_reason;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_installation_id := nullif(trim(p_installation_id), '');
  if v_installation_id is null then
    raise exception 'installation_id is required';
  end if;

  v_reason := coalesce(p_reason, 'signed_out');

  update public.push_device_tokens
  set
    "is_active" = false,
    "deactivation_reason" = v_reason,
    "deactivated_at" = now()
  where "user_id" = v_user_id
    and "installation_id" = v_installation_id
    and "is_active" = true;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."push_token_upsert"("p_installation_id" "text", "p_fcm_token" "text", "p_platform" "public"."push_platform", "p_language_code" "text", "p_country_code" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
declare
  v_user_id uuid := (select auth.uid());
  v_installation_id text;
  v_fcm_token text;
  v_language_code text;
  v_country_code text;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  v_installation_id := nullif(trim(p_installation_id), '');
  if v_installation_id is null then
    raise exception 'installation_id is required';
  end if;

  v_fcm_token := nullif(trim(p_fcm_token), '');
  if v_fcm_token is null then
    raise exception 'fcm_token is required';
  end if;

  v_language_code := lower(nullif(trim(p_language_code), ''));
  if v_language_code is null or v_language_code !~ '^[a-z]{2}$' then
    raise exception 'invalid language_code format';
  end if;

  v_country_code := upper(nullif(trim(p_country_code), ''));
  if v_country_code is not null and v_country_code !~ '^[A-Z]{2}$' then
    raise exception 'invalid country_code format';
  end if;

  -- Serialize concurrent writes for one installation to avoid unique-index races.
  perform pg_advisory_xact_lock(
    hashtext('push_token_upsert'),
    hashtext(v_installation_id)
  );

  update public.push_device_tokens
  set
    "is_active" = false,
    "deactivation_reason" = 'token_rotated',
    "deactivated_at" = now()
  where "installation_id" = v_installation_id
    and "is_active" = true
    and "fcm_token" <> v_fcm_token;

  insert into public.push_device_tokens (
    "user_id",
    "installation_id",
    "fcm_token",
    "platform",
    "language_code",
    "country_code",
    "is_active",
    "deactivation_reason",
    "deactivated_at",
    "last_seen_at"
  )
  values (
    v_user_id,
    v_installation_id,
    v_fcm_token,
    p_platform,
    v_language_code,
    v_country_code,
    true,
    null,
    null,
    now()
  )
  on conflict ("fcm_token")
  do update
  set
    "user_id" = excluded."user_id",
    "installation_id" = excluded."installation_id",
    "platform" = excluded."platform",
    "language_code" = excluded."language_code",
    "country_code" = excluded."country_code",
    "is_active" = true,
    "deactivation_reason" = null,
    "deactivated_at" = null,
    "last_seen_at" = now();
end;
$_$;







CREATE OR REPLACE FUNCTION "public"."push_tokens_cleanup_inactive"("p_older_than" interval DEFAULT '90 days'::interval) RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_deleted integer;
  v_cutoff timestamptz;
begin
  if p_older_than is null or p_older_than <= interval '0' then
    raise exception 'older_than must be greater than zero';
  end if;

  v_cutoff := now() - p_older_than;

  delete from public.push_device_tokens
  where "is_active" = false
    and coalesce("deactivated_at", "updated_at", "created_at") < v_cutoff;

  get diagnostics v_deleted = row_count;
  return v_deleted;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."sync_friendships_from_accepted_request"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."sync_group_users_from_accepted_invitation"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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







CREATE OR REPLACE FUNCTION "public"."sync_meme_template_tags_search_text"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new."tags_search_text" := public.build_meme_template_tags_search_text(new."tags");
  return new;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."touch_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new."updated_at" := now();
  return new;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."update_current_user_name"("p_name" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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
    raise exception 'current user details not found';
  end if;
end;
$$;







CREATE OR REPLACE FUNCTION "public"."upsert_vault_secret"("p_secret_name" "text", "p_secret_value" "text", "p_secret_description" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'vault'
    AS $$
declare
  v_secret_id uuid;
begin
  select s.id
  into v_secret_id
  from vault.secrets s
  where s.name = p_secret_name
  limit 1;

  if v_secret_id is null then
    select vault.create_secret(
      p_secret_value,
      p_secret_name,
      p_secret_description,
      null
    )
    into v_secret_id;
  else
    perform vault.update_secret(
      v_secret_id,
      p_secret_value,
      p_secret_name,
      p_secret_description,
      null
    );
  end if;

  return v_secret_id;
end;
$$;




CREATE OR REPLACE FUNCTION "public"."user_details_memes_other_all_list"("p_user_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."user_details_memes_other_received_list"("p_user_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."user_details_memes_other_sent_list"("p_user_id" "uuid", "p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."user_details_memes_own_all_list"("p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."user_details_memes_own_received_list"("p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;







CREATE OR REPLACE FUNCTION "public"."user_details_memes_own_sent_list"("p_limit" integer DEFAULT 30, "p_cursor_created_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cursor_id" "uuid" DEFAULT NULL::"uuid") RETURNS "public"."list_page"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;
