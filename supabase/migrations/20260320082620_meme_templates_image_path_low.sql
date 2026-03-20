alter table "public"."meme_templates" add column "image_path_low" text not null;

insert into storage.buckets ("id", "name", "public")
values ('meme_templates_low', 'meme_templates_low', false)
on conflict do nothing;

update storage.buckets
set "file_size_limit" = case
  when "id" = 'meme_templates' then 153600
  when "id" = 'meme_templates_low' then 20480
  else "file_size_limit"
end
where "id" in ('meme_templates', 'meme_templates_low');

create policy "storage.objects:meme_templates_low:select:authenticated"
on storage.objects
for select
to authenticated
using (
  "bucket_id" = 'meme_templates_low'
  and exists (
    select 1
    from public.meme_templates t
    where t."image_path_low" = storage.objects."name"
      and t."is_active" = true
  )
);

