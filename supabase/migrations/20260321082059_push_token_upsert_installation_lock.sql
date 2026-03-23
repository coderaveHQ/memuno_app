set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.push_token_upsert(p_installation_id text, p_fcm_token text, p_platform public.push_platform, p_language_code text, p_country_code text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;


