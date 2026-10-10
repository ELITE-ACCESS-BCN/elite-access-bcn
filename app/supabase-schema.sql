-- ELITE ACCESS BCN: esquema de sincronización compartida.
-- Ejecutar en Supabase > SQL Editor con el propietario del proyecto.
create extension if not exists pgcrypto;

create table if not exists public.company_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','employee')),
  created_at timestamptz not null default now()
);

create table if not exists public.app_state (
  id text primary key check (id = 'main'),
  data jsonb not null default '{"incidents":[],"clocks":[],"rounds":[],"sites":[],"staff":[]}'::jsonb,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

alter table public.company_members enable row level security;
alter table public.app_state enable row level security;

create or replace function public.eabcn_is_member()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.company_members where user_id = auth.uid()) $$;

create or replace function public.eabcn_is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.company_members where user_id = auth.uid() and role = 'admin') $$;

revoke all on public.company_members from anon, authenticated;
grant select on public.company_members to authenticated;
grant select, insert, update on public.app_state to authenticated;

drop policy if exists "Members can view own membership" on public.company_members;
create policy "Members can view own membership" on public.company_members
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Company members can read app state" on public.app_state;
create policy "Company members can read app state" on public.app_state
for select to authenticated using (public.eabcn_is_member());

drop policy if exists "Company members can create app state" on public.app_state;
create policy "Company members can create app state" on public.app_state
for insert to authenticated with check (public.eabcn_is_member() and updated_by = auth.uid());

drop policy if exists "Company members can update app state" on public.app_state;
create policy "Company members can update app state" on public.app_state
for update to authenticated using (public.eabcn_is_member()) with check (public.eabcn_is_member() and updated_by = auth.uid());

-- updated_at automático
create or replace function public.eabcn_touch_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;
drop trigger if exists eabcn_app_state_updated_at on public.app_state;
create trigger eabcn_app_state_updated_at before update on public.app_state
for each row execute function public.eabcn_touch_updated_at();

-- Para actualizaciones en tiempo real entre dispositivos:
do $$ begin
  alter publication supabase_realtime add table public.app_state;
exception when duplicate_object then null;
when undefined_object then raise notice 'Publicación supabase_realtime no disponible; actívala en Dashboard > Database > Publications.';
end $$;

-- PASO MANUAL OBLIGATORIO:
-- 1) Crear/invitar usuarios desde Supabase > Authentication > Users.
-- 2) Copiar el UUID del usuario administrador.
-- 3) Ejecutar reemplazando el UUID:
-- insert into public.company_members(user_id, role) values ('UUID-DEL-ADMIN', 'admin');
-- 4) Para cada empleado autorizado:
-- insert into public.company_members(user_id, role) values ('UUID-DEL-EMPLEADO', 'employee');
-- No habilitar el registro público de usuarios. Solo invitar usuarios autorizados.
