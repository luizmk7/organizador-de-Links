-- REFERÊNCIA: já aplicado no Supabase. Não executar novamente no projeto atual.
-- Em um banco novo, defina organizador.access_hash com o SHA-256 de uma chave privada aleatória.
create schema if not exists organizer_private;
revoke all on schema organizer_private from public, anon, authenticated;
create table organizer_private.access_key (id boolean primary key default true check(id), key_hash text not null);
create table organizer_private.groups (id text primary key check(id in ('cafe','burger','pizza','general')),name text not null check(char_length(btrim(name)) between 1 and 40));
create table organizer_private.links (id uuid primary key default gen_random_uuid(),group_id text not null references organizer_private.groups(id),title text not null check(char_length(btrim(title)) between 1 and 100),url text not null check(url ~* '^https?://' and char_length(url)<=8192),created_at timestamptz not null default now(),unique(group_id,url));
alter table organizer_private.access_key enable row level security;
alter table organizer_private.groups enable row level security;
alter table organizer_private.links enable row level security;
insert into organizer_private.access_key(key_hash) values (current_setting('organizador.access_hash'));
insert into organizer_private.groups(id,name) values ('cafe','Vianzo Café'),('burger','Capitão UAU'),('pizza','Pizzaria'),('general','Links gerais');
create function organizer_private.access(p_key text, p_action text default 'read', p_data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
begin
 if p_key is null or length(p_key)<>64 or not exists(select 1 from organizer_private.access_key where key_hash=pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(p_key,'UTF8')),'hex')) then raise exception 'Link de acesso inválido' using errcode='42501'; end if;
 if p_action='group' then
   update organizer_private.groups set name=p_data->>'name' where id=p_data->>'id';
   if not found then raise exception 'Empresa não encontrada'; end if;
 elsif p_action='link' then
   insert into organizer_private.links(id,group_id,title,url) values((p_data->>'id')::uuid,p_data->>'group',p_data->>'title',p_data->>'url')
   on conflict(id) do update set group_id=excluded.group_id,title=excluded.title,url=excluded.url;
 elsif p_action='delete' then
   delete from organizer_private.links where id=(p_data->>'id')::uuid;
 elsif p_action='import' then
   if jsonb_typeof(p_data->'links')<>'array' or jsonb_array_length(p_data->'links')>1000 then raise exception 'Importação inválida'; end if;
   insert into organizer_private.links(group_id,title,url)
   select x."group",x.title,x.url from jsonb_to_recordset(p_data->'links') as x("group" text,title text,url text)
   on conflict(group_id,url) do nothing;
 elsif p_action<>'read' then raise exception 'Operação inválida';
 end if;
 return jsonb_build_object('groups',(select jsonb_agg(jsonb_build_object('id',id,'name',name)) from organizer_private.groups),'links',coalesce((select jsonb_agg(jsonb_build_object('id',id,'group',group_id,'title',title,'url',url) order by created_at,id) from organizer_private.links),'[]'::jsonb));
end $$;
revoke all on function organizer_private.access(text,text,jsonb) from public;
grant usage on schema organizer_private to anon,authenticated;
grant execute on function organizer_private.access(text,text,jsonb) to anon,authenticated;
create function public.organizer_shared(p_key text,p_action text default 'read',p_data jsonb default '{}'::jsonb) returns jsonb
language sql security invoker set search_path='' as $$ select organizer_private.access(p_key,p_action,p_data) $$;
revoke all on function public.organizer_shared(text,text,jsonb) from public;
grant execute on function public.organizer_shared(text,text,jsonb) to anon,authenticated;
