create table folder_items (
    folder_id uuid not null references folder(id) on delete cascade,
    object_ref_id uuid not null,
    in_contribution uuid not null references contribution(id),
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    "namespace" uuid not null,
    constraint folder_items_pkey primary key (folder_id, object_ref_id, in_contribution)
);

create index folder_items_contribution_idx on folder_items using btree (in_contribution, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
folder_items for each row execute function versioning('sys_period', 'folder_items_history', 'true');

create trigger tr_folder_item_delete after delete on
folder_items for each row execute function tr_function_delete_folder_item();

--alter table folder_items add constraint folder_items_obj_ref_fkey foreign key (in_contribution,object_ref_id) references <?>() on delete cascade;