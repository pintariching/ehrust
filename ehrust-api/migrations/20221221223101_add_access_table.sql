-- defines the modality for accessing an com.ethercisrcis.ehr
create table access (
    id uuid primary key default uuid_generate_v4(),
    settings text,
    scheme text, -- name of access control scheme
    "namespace" uuid not null
);

comment on table access is 'defines the modality for accessing an com.ethercis.ehr (security strategy implementation)';
