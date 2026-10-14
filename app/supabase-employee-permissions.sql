-- ELITE ACCESS BCN: tablas operativas separadas y políticas RLS.
-- Ejecuta este archivo en Supabase SQL Editor después de revisar una copia de seguridad.
create table if not exists public.eabcn_incidents (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 incident_at timestamptz not null default now(),
 service text not null, incident_type text not null,
 priority text not null default 'Normal', employee_name text not null,
 facts text not null, action_taken text not null default '',
 created_at timestamptz not null default now()
);
create table if not exists public.eabcn_clocks (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 event_type text not null check(event_type in ('Entrada','Salida')),
 employee_name text not null, service text not null default '',
 note text not null default '', event_at timestamptz not null default now(),
 created_at timestamptz not null default now()
);
create table if not exists public.eabcn_rounds (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 employee_name text not null, service text not null default '',
 note text not null default '', latitude double precision, longitude double precision,
 event_at timestamptz not null default now(), created_at timestamptz not null default now(),
 check(latitude is null or latitude between -90 and 90),
 check(longitude is null or longitude between -180 and 180)
);
create table if not exists public.eabcn_sites (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 name text not null, address text not null default '',
 contact text not null default '', kind text not null default 'Control de acceso',
 created_at timestamptz not null default now()
);
create table if not exists public.eabcn_staff (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 name text not null, job_role text not null, created_at timestamptz not null default now()
);
alter table public.eabcn_incidents enable row level security;
alter table public.eabcn_clocks enable row level security;
alter table public.eabcn_rounds enable row level security;
alter table public.eabcn_sites enable row level security;
alter table public.eabcn_staff enable row level security;
revoke all on public.eabcn_incidents, public.eabcn_clocks, public.eabcn_rounds, public.eabcn_sites, public.eabcn_staff from anon;
grant select, insert, update, delete on public.eabcn_incidents, public.eabcn_clocks, public.eabcn_rounds, public.eabcn_sites, public.eabcn_staff to authenticated;
create policy eabcn_incident_read on public.eabcn_incidents for select to authenticated using (created_by = auth.uid() or public.eabcn_is_admin());
create policy eabcn_incident_insert on public.eabcn_incidents for insert to authenticated with check (created_by = auth.uid() and public.eabcn_is_member());
create policy eabcn_incident_admin_update on public.eabcn_incidents for update to authenticated using (public.eabcn_is_admin()) with check (public.eabcn_is_admin());
create policy eabcn_incident_admin_delete on public.eabcn_incidents for delete to authenticated using (public.eabcn_is_admin());
create policy eabcn_clock_read on public.eabcn_clocks for select to authenticated using (created_by = auth.uid() or public.eabcn_is_admin());
create policy eabcn_clock_insert on public.eabcn_clocks for insert to authenticated with check (created_by = auth.uid() and public.eabcn_is_member());
create policy eabcn_clock_admin_update on public.eabcn_clocks for update to authenticated using (public.eabcn_is_admin()) with check (public.eabcn_is_admin());
create policy eabcn_clock_admin_delete on public.eabcn_clocks for delete to authenticated using (public.eabcn_is_admin());
create policy eabcn_round_read on public.eabcn_rounds for select to authenticated using (created_by = auth.uid() or public.eabcn_is_admin());
create policy eabcn_round_insert on public.eabcn_rounds for insert to authenticated with check (created_by = auth.uid() and public.eabcn_is_member());
create policy eabcn_round_admin_update on public.eabcn_rounds for update to authenticated using (public.eabcn_is_admin()) with check (public.eabcn_is_admin());
create policy eabcn_round_admin_delete on public.eabcn_rounds for delete to authenticated using (public.eabcn_is_admin());
create policy eabcn_site_admin on public.eabcn_sites for all to authenticated using (public.eabcn_is_admin()) with check (public.eabcn_is_admin());
create policy eabcn_staff_admin on public.eabcn_staff for all to authenticated using (public.eabcn_is_admin()) with check (public.eabcn_is_admin());
create index if not exists eabcn_incidents_user_date on public.eabcn_incidents(created_by, incident_at desc);
create index if not exists eabcn_clocks_user_date on public.eabcn_clocks(created_by, event_at desc);
create index if not exists eabcn_rounds_user_date on public.eabcn_rounds(created_by, event_at desc);
