create table composition_history (like composition);

create index composition_history_ehr_idx on composition_history using btree (ehr_id, "namespace");
create index ehr_composition_history on composition_history using btree (id, "namespace");