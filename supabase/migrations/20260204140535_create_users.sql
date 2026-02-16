-- -----------------------------------------------------------------------------
-- USERS (app profile)
-- -----------------------------------------------------------------------------
-- Purpose:
-- - Maintain an app-level profile table `public.users` linked to `auth.users`.
-- - Generate a stable, unique 8-digit friendship code on signup.
-- - Keep `updated_at` in sync via trigger.
--
-- Notes:
-- - We use quoted identifiers for columns to keep naming explicit.
-- - Constraints are always named.
-- - RLS is enabled (policies can be refined later).
-- -----------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new."updated_at" := now();
  return new;
end;
$$;

-- Generates an 8-digit, zero-padded friendship code (no uniqueness check here).
create or replace function public.generate_friendship_code()
returns text
language plpgsql
set search_path = public
as $$
declare
  v_code text;
begin
  v_code := lpad((floor(random() * 100000000))::int::text, 8, '0');
  return v_code;
end;
$$;

create table if not exists public.users (
  "id" uuid not null,
  "created_at" timestamptz not null default now(),
  "updated_at" timestamptz not null default now(),
  "name" text not null,
  "friendship_code" text not null,
  constraint pk_users primary key ("id"),
  constraint uq_users__friendship_code unique ("friendship_code"),
  constraint fk_users__id__auth_users__id
    foreign key ("id") references auth.users ("id")
    on update cascade on delete cascade,
  constraint ck_users__name_length
    check (length("name") >= 2 and length("name") <= 64),
  constraint ck_users__friendship_code_format
    check ("friendship_code" ~ '^[0-9]{8}$')
);

-- Keep updated_at in sync for profile rows.
create trigger trg_users__touch_updated_at
before update on public.users
for each row
execute function public.touch_updated_at();

alter table public.users enable row level security;

-- Basic RLS (can be tightened later).
-- Users can read their own profile.
create policy "users:select:self:authenticated"
on public.users
for select
to authenticated
using ("id" = (select auth.uid()));

-- Users can update only their own profile.
create policy "users:update:self:authenticated"
on public.users
for update
to authenticated
using ("id" = (select auth.uid()))
with check ("id" = (select auth.uid()));

-- Creates a `public.users` row after auth signup, including a unique code.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
  v_code text;
begin
  v_name := new.raw_user_meta_data->'initial_data'->>'name';

  if v_name is null then
    raise exception 'missing user name in raw_user_meta_data.initial_data.name';
  end if;

  -- Retry until we get a unique 8-digit friendship code.
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

-- Hook into `auth.users` insert to provision the app profile.
create trigger trg_auth_users__after_insert__handle_new_user
after insert on auth.users
for each row
execute function public.handle_new_user();
