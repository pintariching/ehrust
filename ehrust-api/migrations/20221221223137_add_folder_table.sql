create table folder (
    id uuid primary key not null default uuid_generate_v4(),
    in_contribution uuid not null references contribution(id) on delete cascade,
    "name" text not null,
    archetype_node_id text not null,
    active bool not null default true,
    details jsonb,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    has_audit uuid not null references audit_details(id) on delete cascade,
    "namespace" uuid not null
);

create index folder_in_contribution_idx on folder using btree (in_contribution, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
folder for each row execute function versioning('sys_period', 'folder_history', 'true');
