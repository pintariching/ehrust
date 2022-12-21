create table contribution_history (like contribution);

create index composition_history_ehr_idx on composition_history using btree (ehr_id, namespace);
create index ehr_composition_history on composition_history using btree (id, namespace);
comment on table contribution is 'contribution table, compositions reference this table';