create table object_ref_history (like object_ref);

create index object_ref_history_contribution_idx on object_ref_history using btree (in_contribution, "namespace");