create table attestation (
    id uuid primary key not null default uuid_generate_v4(),
    proof text,
    reason text,
    is_pending boolean,
    has_audit uuid not null references audit_details(id) on delete cascade,
    reference uuid not null references attestation_ref("ref") on delete cascade,
    "namespace" uuid not null

);

create index attestation_reference_idx on attestation using btree (reference, "namespace");
