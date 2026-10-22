create table public.averymenu_homework_documents (like public.bradymenu_homework_documents including all);
insert into public.averymenu_homework_documents(document_key,content_html) values ('homework','');
alter table public.averymenu_homework_documents enable row level security;
revoke all on public.averymenu_homework_documents from anon,authenticated;
grant select,update on public.averymenu_homework_documents to anon,authenticated;
create policy homework_read on public.averymenu_homework_documents for select to anon,authenticated using(document_key='homework');
create policy homework_update on public.averymenu_homework_documents for update to anon,authenticated using(document_key='homework') with check(document_key='homework');

create table public.averymenu_service_recordings_v1 (
 id uuid primary key,
 name text not null default 'Avery Steinberg' check(name='Avery Steinberg'),
 start_time timestamptz not null,
 passage_key_text text not null check(char_length(passage_key_text) between 1 and 120),
 mime_type text not null check(mime_type in ('audio/webm','audio/ogg','audio/mp4')),
 audio_base64 text not null check(char_length(audio_base64) between 1 and 12000000)
);
alter table public.averymenu_service_recordings_v1 enable row level security;
revoke all on public.averymenu_service_recordings_v1 from anon,authenticated;
grant select,insert,update on public.averymenu_service_recordings_v1 to anon,authenticated;
create policy current_recording_only on public.averymenu_service_recordings_v1 for all to anon,authenticated
using(id::text = (current_setting('request.headers',true)::jsonb ->> 'x-recording-id') and name='Avery Steinberg')
with check(id::text = (current_setting('request.headers',true)::jsonb ->> 'x-recording-id') and name='Avery Steinberg');

create table public.avery_status_items_v1 (like public.brady_status_items_v1 including all);
create table public.avery_status_dates_v1 (like public.brady_status_dates_v1 including all);
insert into public.avery_status_items_v1 select * from public.brady_status_items_v1 where sort_order <= 12;
insert into public.avery_status_dates_v1
select to_char(d,'YYYY-MM-DD'),to_char(d,'FMMM/FMDD'),row_number() over(order by d)::int
from generate_series('2026-10-19'::date,'2027-08-09'::date,'7 days'::interval) d;
create table public.avery_status_cells_v1 (
 item_key text not null references public.avery_status_items_v1(item_key) on delete cascade,
 date_key text not null references public.avery_status_dates_v1(date_key) on delete cascade,
 status text not null check(status in ('red','yellow','green')),
 primary key(item_key,date_key)
);
create table public.avery_status_notes_v1 (
 item_key text primary key references public.avery_status_items_v1(item_key) on delete cascade,
 body text not null default ''
);
do $$
declare t text; p record;
begin
 foreach t in array array['items','dates','cells','notes'] loop
 execute format('alter table public.avery_status_%I enable row level security', t || '_v1');
 execute format('revoke all on public.avery_status_%I from anon,authenticated', t || '_v1');
 if t <> 'notes' then
 execute format('grant select on public.avery_status_%I to anon,authenticated', t || '_v1');
 else
 execute 'grant select on public.avery_status_notes_v1 to authenticated';
 end if;
 if t in ('cells','notes') then
 execute format('grant insert,update,delete on public.avery_status_%I to authenticated',t || '_v1');
 end if;
 for p in select * from pg_policies where schemaname='public' and tablename='brady_status_' || t || '_v1' loop
 execute format('create policy %I on public.%I for %s to %s%s%s',p.policyname,'avery_status_' || t || '_v1',p.cmd,array_to_string(p.roles,','),case when p.qual is not null then ' using (' || p.qual || ')' else '' end,case when p.with_check is not null then ' with check (' || p.with_check || ')' else '' end);
 end loop;
 end loop;
end $$;
alter publication supabase_realtime add table public.avery_status_cells_v1;
notify pgrst,'reload schema';
