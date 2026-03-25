alter table "public"."ugc_reports" drop constraint "fk_ugc_reports_target_meme";

alter table "public"."ugc_reports" drop constraint "fk_ugc_reports_target_user";

alter table "public"."user_blocks" add constraint "fk_user_blocks_blocked_id__auth_users__id" FOREIGN KEY (blocked_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."user_blocks" validate constraint "fk_user_blocks_blocked_id__auth_users__id";

alter table "public"."user_blocks" add constraint "fk_user_blocks_blocker_id__auth_users__id" FOREIGN KEY (blocker_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."user_blocks" validate constraint "fk_user_blocks_blocker_id__auth_users__id";

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_target_meme" FOREIGN KEY (target_meme_id) REFERENCES public.memes(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_target_meme";

alter table "public"."ugc_reports" add constraint "fk_ugc_reports_target_user" FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ugc_reports" validate constraint "fk_ugc_reports_target_user";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.cleanup_group_after_user_removed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_meme_after_recipient_removed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;


