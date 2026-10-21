-- CGPA Tracker: run this once in Supabase (Dashboard -> SQL Editor -> New query -> Run).
-- One row per user holds that user's whole tracker as JSON.
-- Row Level Security makes sure a signed-in user can only read or write their own row.

create table if not exists public.tracker_data (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  -- keeps any single account from storing huge blobs (a full degree is a few KB)
  constraint tracker_data_size check (pg_column_size(data) < 500000)
);

alter table public.tracker_data enable row level security;

-- Only signed-in users get access, and only to their own row. Anonymous visitors get nothing.
revoke all on public.tracker_data from anon;
grant select, insert, update, delete on public.tracker_data to authenticated;

drop policy if exists "Read own tracker"   on public.tracker_data;
drop policy if exists "Insert own tracker" on public.tracker_data;
drop policy if exists "Update own tracker" on public.tracker_data;
drop policy if exists "Delete own tracker" on public.tracker_data;

create policy "Read own tracker" on public.tracker_data
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Insert own tracker" on public.tracker_data
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Update own tracker" on public.tracker_data
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Delete own tracker" on public.tracker_data
  for delete to authenticated using ((select auth.uid()) = user_id);

-- The server stamps updated_at on every save, so devices can tell which copy is newest.
create or replace function public.tracker_data_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tracker_data_touch on public.tracker_data;
create trigger tracker_data_touch
  before update on public.tracker_data
  for each row execute function public.tracker_data_touch();
