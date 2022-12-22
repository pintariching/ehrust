create table participation (
    id uuid primary key not null default uuid_generate_v4(),
    event_context uuid not null references event_context(id) on delete cascade,
    performer uuid references party_identified(id),
    "function" dv_coded_text,
    "mode" dv_coded_text,
    time_lower timestamp,
    time_lower_tz text,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    time_upper timestamp,
    time_upper_tz text,
    "namespace" uuid not null
);

create index context_participation_index on participation using btree (event_context, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
participation for each row execute function versioning('sys_period', 'participation_history', 'true');
