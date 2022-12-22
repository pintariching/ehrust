create table event_context (
    id uuid primary key not null default uuid_generate_v4(),
    composition_id uuid references composition(id) on delete cascade,
    start_time timestamp not null,
    start_time_tzid text null,
    end_time timestamp null,
    end_time_tzid text null,
    facility uuid null references party_identified(id),
    "location" text null,
    other_context jsonb null,
    setting dv_coded_text null,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    "namespace" uuid not null
);

create unique index context_composition_id_idx on event_context using btree (composition_id, "namespace");
create index context_facility_idx on event_context using btree (facility, "namespace");
create index context_setting_idx on event_context using btree (setting, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
event_context for each row execute function versioning('sys_period', 'event_context_history', 'true');
