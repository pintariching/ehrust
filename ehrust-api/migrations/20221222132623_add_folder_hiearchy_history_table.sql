create table folder_hierarchy_history (like folder_hierarchy);

create index folder_hierarchy_history_contribution_idx on folder_hierarchy_history using btree (in_contribution, "namespace");
