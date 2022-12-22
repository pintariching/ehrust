-- change history table
create table status_history (like "status");

CREATE INDEX ehr_status_history ON status_history USING btree (id, "namespace");
CREATE INDEX status_history_ehr_idx ON status_history USING btree (ehr_id, "namespace");