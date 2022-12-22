CREATE TABLE attestation_ref (
    "ref" uuid primary key not null default uuid_generate_v4(),
    "namespace" uuid not null
);