CREATE TABLE participation_history (like participation);

CREATE INDEX ehr_participation_history ON participation_history USING btree (id, "namespace");
CREATE INDEX participation_history_event_context_idx ON participation_history USING btree (event_context, "namespace");