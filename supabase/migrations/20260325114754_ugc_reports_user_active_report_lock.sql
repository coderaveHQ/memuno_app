CREATE UNIQUE INDEX ugc_reports_active_user_report_per_reporter_target_uidx ON public.ugc_reports USING btree (reporter_id, target_user_id) WHERE ((target_type = 'user'::public.ugc_report_target_type) AND (target_user_id IS NOT NULL) AND (status = ANY (ARRAY['open'::public.ugc_report_status, 'in_review'::public.ugc_report_status])));

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.ugc_report_user_can_create(p_target_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    (select auth.uid()) is not null
    and p_target_user_id is not null
    and not exists (
      select 1
      from public.ugc_reports ur
      where ur.reporter_id = (select auth.uid())
        and ur.target_type = 'user'::public.ugc_report_target_type
        and ur.target_user_id = p_target_user_id
        and ur.status in (
          'open'::public.ugc_report_status,
          'in_review'::public.ugc_report_status
        )
    );
$function$
;

CREATE OR REPLACE FUNCTION public.ugc_report_create(p_target_type public.ugc_report_target_type, p_target_id uuid, p_reason public.ugc_report_reason)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_reporter_id uuid := (select auth.uid());
begin
  if v_reporter_id is null then
    raise exception 'not authenticated';
  end if;

  if p_target_type is null then
    raise exception 'target_type is required';
  end if;

  if p_target_id is null then
    raise exception 'target_id is required';
  end if;

  if p_reason is null then
    raise exception 'reason is required';
  end if;

  if p_target_type = 'user'::public.ugc_report_target_type then
    if not exists (
      select 1
      from public.users u
      where u.id = p_target_id
    ) then
      raise exception 'target user not found';
    end if;

    if not public.ugc_report_user_can_create(p_target_id) then
      raise exception using
        errcode = '23505',
        message = 'active user report already exists';
    end if;

    insert into public.ugc_reports (
      reporter_id,
      target_type,
      target_user_id,
      reason
    )
    values (
      v_reporter_id,
      'user'::public.ugc_report_target_type,
      p_target_id,
      p_reason
    );

    return;
  end if;

  if p_target_type = 'group'::public.ugc_report_target_type then
    if not exists (
      select 1
      from public.groups g
      where g.id = p_target_id
    ) then
      raise exception 'target group not found';
    end if;

    insert into public.ugc_reports (
      reporter_id,
      target_type,
      target_group_id,
      reason
    )
    values (
      v_reporter_id,
      'group'::public.ugc_report_target_type,
      p_target_id,
      p_reason
    );

    return;
  end if;

  if p_target_type = 'meme'::public.ugc_report_target_type then
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
      reason
    )
    values (
      v_reporter_id,
      'meme'::public.ugc_report_target_type,
      p_target_id,
      p_reason
    );

    return;
  end if;

  raise exception 'target_type must be `user`, `group`, or `meme`';
end;
$function$
;


