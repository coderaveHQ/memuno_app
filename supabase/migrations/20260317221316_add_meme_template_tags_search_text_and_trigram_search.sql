-- -----------------------------------------------------------------------------
-- Meme template tag-search improvements
-- -----------------------------------------------------------------------------

create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

alter table public.meme_templates
add column "tags_search_text" text not null default '';

create function public.build_meme_template_tags_search_text(
  p_tags text[]
)
returns text
language sql
stable
set search_path = public, extensions
as $$
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

create function public.sync_meme_template_tags_search_text()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new."tags_search_text" := public.build_meme_template_tags_search_text(new."tags");
  return new;
end;
$$;

update public.meme_templates
set "tags_search_text" = public.build_meme_template_tags_search_text("tags");

drop trigger if exists trg_meme_templates__sync_tags_search_text
on public.meme_templates;

create trigger trg_meme_templates__sync_tags_search_text
before insert or update of "tags" on public.meme_templates
for each row
execute function public.sync_meme_template_tags_search_text();

drop index if exists public.meme_templates_tags_search_text_trgm_idx;

create index meme_templates_tags_search_text_trgm_idx
on public.meme_templates
using gin ("tags_search_text" gin_trgm_ops);

create or replace function public.meme_templates_list(
  p_search text default null,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns public.list_page
language sql
security definer
set search_path = public, extensions
as $$
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

-- -----------------------------------------------------------------------------
-- Function metadata
-- -----------------------------------------------------------------------------

comment on function public.build_meme_template_tags_search_text(text[]) is
'Builds one normalized search-text string from public.meme_templates.tags for fast trigram-backed and accent-insensitive meme template search.';

comment on function public.sync_meme_template_tags_search_text() is
'Synchronizes public.meme_templates.tags_search_text from public.meme_templates.tags before insert or update of tags.';

comment on function public.meme_templates_list(text, integer, timestamptz, uuid) is
'Returns one cursor-paginated page of active meme templates, optionally filtered by trigram-backed, accent-insensitive, relevance-ranked tag search.';

-- -----------------------------------------------------------------------------
-- RPC execute permissions
-- -----------------------------------------------------------------------------

revoke all on function public.build_meme_template_tags_search_text(text[]) from public;
revoke all on function public.sync_meme_template_tags_search_text() from public;
revoke all on function public.meme_templates_list(text, integer, timestamptz, uuid) from public;

grant execute on function public.meme_templates_list(text, integer, timestamptz, uuid) to authenticated;
