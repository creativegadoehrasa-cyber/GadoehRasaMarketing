-- Gadoeh Rasa Marketing Workspace
-- Jalankan seluruh script ini di Supabase Dashboard > SQL Editor.

create table if not exists public.workspace_members (
  email text primary key,
  added_at timestamptz not null default now()
);

alter table public.workspace_members enable row level security;

-- User hanya boleh melihat keanggotaan miliknya sendiri.
drop policy if exists "Members can read own membership" on public.workspace_members;
create policy "Members can read own membership"
on public.workspace_members for select
to authenticated
using (lower(email) = lower(auth.jwt() ->> 'email'));

grant select on public.workspace_members to authenticated;

-- Fungsi pemeriksa keanggotaan workspace.
create or replace function public.is_gadoeh_workspace_member()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.workspace_members
    where lower(email) = lower(auth.jwt() ->> 'email')
  );
$$;

grant execute on function public.is_gadoeh_workspace_member() to authenticated;

create table if not exists public.workspace_state (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.workspace_state enable row level security;

drop policy if exists "Authenticated users can read workspace" on public.workspace_state;
drop policy if exists "Authenticated users can insert workspace" on public.workspace_state;
drop policy if exists "Authenticated users can update workspace" on public.workspace_state;
drop policy if exists "Workspace members can read workspace" on public.workspace_state;
drop policy if exists "Workspace members can insert workspace" on public.workspace_state;
drop policy if exists "Workspace members can update workspace" on public.workspace_state;

create policy "Workspace members can read workspace"
on public.workspace_state for select
to authenticated
using (public.is_gadoeh_workspace_member());

create policy "Workspace members can insert workspace"
on public.workspace_state for insert
to authenticated
with check (public.is_gadoeh_workspace_member());

create policy "Workspace members can update workspace"
on public.workspace_state for update
to authenticated
using (public.is_gadoeh_workspace_member())
with check (public.is_gadoeh_workspace_member());

grant select, insert, update on public.workspace_state to authenticated;

-- Aktifkan realtime untuk sinkronisasi perubahan antar pengguna.
do $$
begin
  alter publication supabase_realtime add table public.workspace_state;
exception
  when duplicate_object then null;
  when undefined_object then
    raise notice 'Publication supabase_realtime belum tersedia; aktifkan Realtime untuk workspace_state dari Dashboard.';
end $$;

-- Setelah akun tim dibuat melalui form website, masukkan email anggota yang diizinkan:
-- insert into public.workspace_members(email) values ('email-kamu@domain.com')
-- on conflict (email) do nothing;
