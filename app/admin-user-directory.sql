-- ELITE ACCESS BCN: admin user directory for linking accounts safely.
create or replace function public.eabcn_admin_list_users()
returns table(user_id uuid, email text, role text)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not public.eabcn_is_admin() then
    raise exception 'Solo el administrador puede consultar las cuentas.';
  end if;
  return query
    select u.id, u.email::text,
      (select cm.role from public.company_members cm where cm.user_id=u.id limit 1)
    from auth.users u
    where u.deleted_at is null
    order by u.email;
end;
$$;
revoke all on function public.eabcn_admin_list_users() from public, anon;
grant execute on function public.eabcn_admin_list_users() to authenticated;
