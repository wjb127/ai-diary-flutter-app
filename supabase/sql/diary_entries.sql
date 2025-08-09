-- AI Diary App: diary_entries schema, RLS, policies, indexes, triggers

-- 0) Required extension for gen_random_uuid()
create extension if not exists pgcrypto;

-- 1) Table
create table if not exists public.diary_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  date date not null,
  title text not null,
  original_content text not null,
  generated_content text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2) RLS
alter table public.diary_entries enable row level security;

-- 3) Unique index (prevent duplicate entries per user per date)
create unique index if not exists diary_entries_user_date_idx
  on public.diary_entries (user_id, date);

-- 4) updated_at auto-update trigger
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_diary_entries_updated_at on public.diary_entries;
create trigger update_diary_entries_updated_at
before update on public.diary_entries
for each row execute function public.update_updated_at_column();

-- 5) RLS policies (own rows only)
drop policy if exists "select_own" on public.diary_entries;
create policy "select_own" on public.diary_entries
  for select using (auth.uid() = user_id);

drop policy if exists "insert_own" on public.diary_entries;
create policy "insert_own" on public.diary_entries
  for insert with check (auth.uid() = user_id);

drop policy if exists "update_own" on public.diary_entries;
create policy "update_own" on public.diary_entries
  for update using (auth.uid() = user_id);

drop policy if exists "delete_own" on public.diary_entries;
create policy "delete_own" on public.diary_entries
  for delete using (auth.uid() = user_id);


