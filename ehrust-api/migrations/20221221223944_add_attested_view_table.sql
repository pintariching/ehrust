create table attested_view (
    id uuid primary key not null default uuid_generate_v4(),
    attestation_id uuid references attestation(id) on delete cascade,
    --  DvMultimedia
    alternate_text text,
    compression_algorithm text,
    media_type text,
    "data" bytea,
    integrity_check bytea,
    integrity_check_algorithm text,
    thumbnail uuid, -- another multimedia holding the thumbnail
    uri text,
    "namespace" uuid not null
);

create index attested_view_attestation_idx on attested_view using btree (attestation_id, namespace);
