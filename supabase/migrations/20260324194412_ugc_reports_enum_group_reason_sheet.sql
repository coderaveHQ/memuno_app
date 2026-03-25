create type "public"."ugc_report_reason" as enum ('spam', 'harassment', 'hate_speech', 'sexual_content', 'violence', 'scam', 'other');

create type "public"."ugc_report_status" as enum ('open', 'in_review', 'resolved', 'rejected');

create type "public"."ugc_report_target_type" as enum ('user', 'group', 'meme');

alter table "public"."ugc_reports" drop constraint "ck_ugc_reports_reason_not_empty";

alter table "public"."ugc_reports" drop constraint "ck_ugc_reports_status_not_empty";

alter table "public"."ugc_reports" drop constraint "ck_ugc_reports_target_type";

alter table "public"."ugc_reports" drop constraint "ck_ugc_reports_target_shape";

drop function if exists "public"."ugc_report_create"(p_target_type text, p_target_id uuid, p_reason text, p_details text);

alter table "public"."ugc_reports" drop column "details";

alter table "public"."ugc_reports" add column "target_group_id" uuid;

alter table "public"."ugc_reports" alter column "reason" set data type public.ugc_report_reason using "reason"::public.ugc_report_reason;

alter table "public"."ugc_reports" alter column "status" set default 'open'::public.ugc_report_status;

alter table "public"."ugc_reports" alter column "status" set data type public.ugc_report_status using "status"::public.ugc_report_status;

alter table "public"."ugc_reports" alter column "target_type" set data type public.ugc_report_target_type using "target_type"::public.ugc_report_target_type;

CREATE INDEX ugc_reports_target_group_created_at_idx ON public.ugc_reports USING btree (target_group_id, created_at DESC, id DESC) WHERE (target_group_id IS NOT NULL);

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_target_group" FOREIGN KEY (target_group_id) REFERENCES public.groups(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_target_group";

alter table "public"."ugc_reports" add constraint "ck_ugc_reports_target_shape" CHECK ((((target_type = 'user'::public.ugc_report_target_type) AND (target_user_id IS NOT NULL) AND (target_group_id IS NULL) AND (target_meme_id IS NULL)) OR ((target_type = 'group'::public.ugc_report_target_type) AND (target_user_id IS NULL) AND (target_group_id IS NOT NULL) AND (target_meme_id IS NULL)) OR ((target_type = 'meme'::public.ugc_report_target_type) AND (target_user_id IS NULL) AND (target_group_id IS NULL) AND (target_meme_id IS NOT NULL)))) not valid;

alter table "public"."ugc_reports" validate constraint "ck_ugc_reports_target_shape";

set check_function_bodies = off;

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

CREATE OR REPLACE FUNCTION public.ugc_report_reason_list()
 RETURNS TABLE(reason text)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select enum_value::text as reason
  from unnest(enum_range(null::public.ugc_report_reason)) as enum_value
$function$
;


