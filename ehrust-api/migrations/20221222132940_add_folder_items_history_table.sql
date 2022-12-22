create table folder_items_history (like folder_items);

create index folder_hist_idx on folder_items_history using btree (folder_id, object_ref_id, in_contribution, "namespace");
create index folder_items_history_contribution_idx on folder_items_history using btree (in_contribution, "namespace");