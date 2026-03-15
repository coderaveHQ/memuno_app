alter table public.memes
  alter column "template_id" set not null;

create or replace function public.meme_create(
  p_image_path text,
  p_template_id uuid,
  p_recipient_ids uuid[],
  p_aspect_ratio double precision
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_meme public.memes;
  v_recipient_ids uuid[];
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

  if p_recipient_ids is null or array_length(p_recipient_ids, 1) is null then
    raise exception 'recipient_ids is required';
  end if;

  select array_agg(distinct recipient_id)
  into v_recipient_ids
  from (
    select r_id as recipient_id
    from unnest(p_recipient_ids) as r_id
    where r_id is not null
      and r_id <> v_user_id
  ) normalized;

  if v_recipient_ids is null or array_length(v_recipient_ids, 1) is null then
    raise exception 'recipient_ids is required';
  end if;

  if exists (
    select 1
    from unnest(v_recipient_ids) as r_id
    where not exists (
      select 1
      from public.friendships f
      where f."user_id" = v_user_id
        and f."friend_id" = r_id
    )
  ) then
    raise exception 'all recipients must be friends';
  end if;

  insert into public.memes ("user_id", "template_id", "image_path", "aspect_ratio")
  values (v_user_id, p_template_id, p_image_path, p_aspect_ratio)
  returning *
  into v_meme;

  insert into public.meme_recipients ("meme_id", "user_id")
  select v_meme."id", r_id
  from unnest(v_recipient_ids) as r_id
  on conflict do nothing;
end;
$$;

comment on function public.meme_create(text, uuid, uuid[], double precision) is
'Creates one meme for auth.uid(), persists image_path + template_id + aspect_ratio, validates friend recipients, and inserts recipient edges.';
