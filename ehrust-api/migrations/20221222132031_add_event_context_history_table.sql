create table event_context_history (like event_context);
create index ehr_event_context_history on event_context_history using btree (id, "namespace");
create index event_context_history_composition_idx on event_context_history using btree (composition_id, "namespace");