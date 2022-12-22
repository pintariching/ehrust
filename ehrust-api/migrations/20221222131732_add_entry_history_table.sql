create table entry_history (like "entry");

create index ehr_entry_history on entry_history using btree (id, "namespace");
create index entry_history_composition_idx on entry_history using btree (composition_id, "namespace");