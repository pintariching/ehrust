create table folder_hierarchy (
    parent_folder uuid not null references folder(id) on delete cascade on update cascade deferrable,
    child_folder uuid not null,
    in_contribution uuid null references contribution(id) on delete cascade,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    "namespace" uuid not null,
    constraint folder_hierarchy_pkey primary key (parent_folder, child_folder),
    constraint uq_folderhierarchy_parent_child unique (parent_folder, child_folder)
);

create index fki_folder_hierarchy_parent_fk on folder_hierarchy using btree (parent_folder, "namespace");
create index folder_hierarchy_in_contribution_idx on folder_hierarchy using btree (in_contribution, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
folder_hierarchy for each row execute function versioning('sys_period', 'folder_hierarchy_history', 'true');
