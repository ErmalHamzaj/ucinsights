-- UCInsights — schema update
-- Run in Supabase dashboard → SQL Editor
-- Safe to run multiple times (uses IF NOT EXISTS / ADD COLUMN IF NOT EXISTS)

-- ─────────────────────────────────────────────────────────────────
-- 1. Add missing columns to user_state (visits + meds_taken)
-- ─────────────────────────────────────────────────────────────────
alter table public.user_state
  add column if not exists visits    jsonb not null default '[]'::jsonb,
  add column if not exists meds_taken jsonb not null default '{}'::jsonb;

-- ─────────────────────────────────────────────────────────────────
-- 2. user_profiles — personal identity (name, age, gender, country)
-- ─────────────────────────────────────────────────────────────────
create table if not exists public.user_profiles (
  user_id    uuid        primary key references auth.users(id) on delete cascade,
  first_name text,
  last_name  text,
  email      text,
  age        int,
  gender     text,
  country    text,
  updated_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;

drop policy if exists "own profile select" on public.user_profiles;
create policy "own profile select" on public.user_profiles
  for select using (auth.uid() = user_id);

drop policy if exists "own profile insert" on public.user_profiles;
create policy "own profile insert" on public.user_profiles
  for insert with check (auth.uid() = user_id);

drop policy if exists "own profile update" on public.user_profiles;
create policy "own profile update" on public.user_profiles
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
