create table session_log (
    id uuid primary key not null default uuid_generate_v4(),
    subject_id text not null,
    node_id text,
    session_id text,
    session_name text,
    session_time timestamp,
    ip_address text,
    "namespace" uuid not null
);