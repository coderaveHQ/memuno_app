create function public.meme_delete(
  p_meme_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
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

comment on function public.meme_delete(uuid) is
'Deletes one meme owned by auth.uid().';

revoke all on function public.meme_delete(uuid) from public;
grant execute on function public.meme_delete(uuid) to authenticated;
