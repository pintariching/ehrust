create table folder_history (like folder);

create index folder_history_contribution_idx on folder_history using btree (in_contribution, "namespace");