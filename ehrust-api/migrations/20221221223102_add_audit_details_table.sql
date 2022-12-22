create table audit_details (
    id uuid primary key default uuid_generate_v4(),
    system_id uuid not null references "system"(id),
    committer uuid not null references party_identified(id),
    time_committed timestamp default now(),
    time_committed_tzid text not null,
    change_type contribution_change_type not null,
    "description" text,
    "namespace" uuid not null
);
