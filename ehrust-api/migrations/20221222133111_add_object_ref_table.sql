create table object_ref (
    id_namespace text not null,
    "type" text not null,
    id uuid not null,
    in_contribution uuid not null references contribution(id) on delete cascade,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    "namespace" uuid not null,
    constraint object_ref_pkey primary key (id, in_contribution)
);

create index obj_ref_in_contribution_idx on object_ref using btree (in_contribution, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
object_ref for each row execute function versioning('sys_period', 'object_ref_history', 'true');
