create table contribution (
    id uuid primary key default uuid_generate_v4(),
    ehr_id uuid references ehr(id) on delete cascade,
    contribution_type "contribution_data_type",
    state "contribution_state",
    signature text,
    has_audit uuid references audit_details(id) on delete cascade,
    "namespace" uuid not null
);

create index contribution_ehr_idx on contribution using btree (ehr_id, namespace);